#!/bin/zsh
# close-app-windows.sh - 互動式選擇要關閉哪個 App 或螢幕的所有視窗
# 需要輔助使用權限

set -e

# 排除的 App（終端機）
EXCLUDE_APPS=("Ghostty" "Terminal" "iTerm2" "kitty" "Alacritty" "WezTerm")

# 取得螢幕資訊和視窗資訊，輸出 JSON 格式
get_screens_and_windows() {
    osascript -l JavaScript <<'EOF'
const app = Application.currentApplication();
app.includeStandardAdditions = true;

const se = Application("System Events");
const screens = [];

ObjC.import('AppKit');
const nsScreens = $.NSScreen.screens;
for (let i = 0; i < nsScreens.count; i++) {
    const screen = nsScreens.objectAtIndex(i);
    const frame = screen.frame;
    const name = screen.localizedName.js;
    screens.push({
        name: name,
        x: frame.origin.x,
        y: frame.origin.y,
        width: frame.size.width,
        height: frame.size.height
    });
}

const windows = [];
const excludeApps = ["Ghostty", "Terminal", "iTerm2", "kitty", "Alacritty", "WezTerm"];
const procs = se.processes.whose({visible: true})();

for (const proc of procs) {
    try {
        const appName = proc.name();
        if (excludeApps.includes(appName)) continue;

        const wins = proc.windows();
        for (const win of wins) {
            try {
                const pos = win.position();
                const size = win.size();
                windows.push({
                    app: appName,
                    x: pos[0],
                    y: pos[1],
                    width: size[0],
                    height: size[1]
                });
            } catch(e) {}
        }
    } catch(e) {}
}

JSON.stringify({screens: screens, windows: windows});
EOF
}

# 關閉指定 App 的所有視窗
close_windows_of_app() {
    local app_name="$1"
    osascript 2>/dev/null <<EOF
tell application "System Events"
    tell process "$app_name"
        set winList to every window
        repeat with w in winList
            try
                click button 1 of w
            end try
        end repeat
    end tell
end tell
EOF
}

# 主程式
main() {
    echo "正在掃描螢幕和視窗..."
    echo ""

    local json_data
    json_data=$(get_screens_and_windows)

    # 用 Python 處理所有資料
    local menu_data
    menu_data=$(/usr/bin/python3 <<PYEOF
import json

data = json.loads('''${json_data}''')
screens = data['screens']
windows = data['windows']

# macOS 坐標系: 主螢幕左下角是 (0,0)，y 向上增加
# 視窗的 position 是左上角，坐標系是主螢幕左上角 (0,0)，y 向下增加
# 需要轉換

# 找主螢幕（y=0 的那個）
main_screen_height = 0
for s in screens:
    if s['y'] == 0:
        main_screen_height = s['height']
        break

def get_screen_index(wx, wy):
    # 把窗口的 y 座標轉換成 NSScreen 座標系
    # NSScreen: 左下角 (0,0)，y 向上
    # Window: 左上角 (0,0)，y 向下
    for i, s in enumerate(screens):
        sx = s['x']
        # NSScreen 的 y 是左下角，要轉換
        sy_bottom = s['y']
        sw = s['width']
        sh = s['height']

        # 檢查 x 是否在範圍內
        if sx <= wx < sx + sw:
            # 對於 y，簡化處理：如果只有一個螢幕，所有視窗都在上面
            # 如果有多個螢幕，用 x 座標來區分（假設螢幕是左右排列）
            return i
    return 0

# 統計每個螢幕的 app
screen_apps = {}
for w in windows:
    idx = get_screen_index(w['x'], w['y'])
    if idx not in screen_apps:
        screen_apps[idx] = {}
    app = w['app']
    screen_apps[idx][app] = screen_apps[idx].get(app, 0) + 1

# 輸出
print("SCREENS")
for i, s in enumerate(screens):
    print(f"{i}|{s['name']}|{s['x']}|{s['y']}|{s['width']}|{s['height']}")

print("APPS")
item_num = 1
for sidx in range(len(screens)):
    apps = screen_apps.get(sidx, {})
    for app, cnt in sorted(apps.items()):
        print(f"{item_num}|{sidx}|{app}|{cnt}")
        item_num += 1

print("SCREEN_APPS")
for sidx in range(len(screens)):
    apps = list(screen_apps.get(sidx, {}).keys())
    print(f"{sidx}|{','.join(apps)}")
PYEOF
)

    # 解析資料
    local -a screen_names screen_xs screen_ys screen_widths screen_heights
    local -a item_apps item_screens item_counts
    local -A screen_app_list  # screen_idx -> "app1,app2,app3"
    local parsing=""

    while IFS= read -r line; do
        case "$line" in
            SCREENS) parsing="screens"; continue ;;
            APPS) parsing="apps"; continue ;;
            SCREEN_APPS) parsing="screen_apps"; continue ;;
        esac

        case "$parsing" in
            screens)
                local idx name sx sy sw sh
                IFS='|' read -r idx name sx sy sw sh <<< "$line"
                screen_names+=("$name")
                screen_xs+=("$sx")
                screen_ys+=("$sy")
                screen_widths+=("$sw")
                screen_heights+=("$sh")
                ;;
            apps)
                local num sidx app cnt
                IFS='|' read -r num sidx app cnt <<< "$line"
                item_apps+=("$app")
                item_screens+=("$sidx")
                item_counts+=("$cnt")
                ;;
            screen_apps)
                local sidx apps_str
                IFS='|' read -r sidx apps_str <<< "$line"
                screen_app_list[$sidx]="$apps_str"
                ;;
        esac
    done <<< "$menu_data"

    local num_screens=${#screen_names[@]}
    local letters=("A" "B" "C" "D" "E" "F")

    # 顯示選單
    local item_idx=1
    for ((s=1; s<=num_screens; s++)); do
        local letter="${letters[$s]}"
        local sname="${screen_names[$s]}"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "【${letter}】螢幕: ${sname}"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        local has_apps=false
        for ((i=1; i<=${#item_apps[@]}; i++)); do
            if [[ "${item_screens[$i]}" == "$((s-1))" ]]; then
                printf "  %2d) %s (%s 個視窗)\n" "$item_idx" "${item_apps[$i]}" "${item_counts[$i]}"
                ((item_idx++))
                has_apps=true
            fi
        done

        if [[ "$has_apps" == false ]]; then
            echo "  (沒有視窗)"
        fi
        echo ""
    done

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "輸入 A/B/C/D 關閉該螢幕所有視窗"
    echo "輸入數字關閉該 App 的視窗"
    echo "輸入 0 取消"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    read -r "choice?選擇: "

    # 關閉螢幕上所有 App 的視窗
    close_screen() {
        local screen_idx=$1
        local apps_str="${screen_app_list[$screen_idx]}"
        if [[ -n "$apps_str" ]]; then
            local -a apps_to_close
            IFS=',' read -rA apps_to_close <<< "$apps_str"
            for app in "${apps_to_close[@]}"; do
                [[ -n "$app" ]] && close_windows_of_app "$app"
            done
        fi
    }

    case "$choice" in
        0)
            echo "已取消"
            exit 0
            ;;
        [Aa])
            if [[ $num_screens -ge 1 ]]; then
                echo "正在關閉螢幕 A (${screen_names[1]}) 上的所有視窗..."
                close_screen 0
                echo "完成！"
            fi
            ;;
        [Bb])
            if [[ $num_screens -ge 2 ]]; then
                echo "正在關閉螢幕 B (${screen_names[2]}) 上的所有視窗..."
                close_screen 1
                echo "完成！"
            fi
            ;;
        [Cc])
            if [[ $num_screens -ge 3 ]]; then
                echo "正在關閉螢幕 C (${screen_names[3]}) 上的所有視窗..."
                close_screen 2
                echo "完成！"
            fi
            ;;
        [Dd])
            if [[ $num_screens -ge 4 ]]; then
                echo "正在關閉螢幕 D (${screen_names[4]}) 上的所有視窗..."
                close_screen 3
                echo "完成！"
            fi
            ;;
        [0-9]*)
            if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le ${#item_apps[@]} ]]; then
                local app="${item_apps[$choice]}"
                echo "正在關閉 $app 的所有視窗..."
                close_windows_of_app "$app"
                echo "完成！"
            else
                echo "無效的選擇"
                exit 1
            fi
            ;;
        *)
            echo "無效的選擇"
            exit 1
            ;;
    esac
}

main "$@"
