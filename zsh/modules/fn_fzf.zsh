# FZF Related Functions

# FZF with preview
function fzf-pre() {
  fzf -m --height 50% \
    --layout=reverse \
    --inline-info \
    --preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200' \
    --preview-window 'right,50%,+{2}+3/3,~3,noborder' \
    --bind '?:toggle-preview'
}

# Ripgrep with nvim (current dir)
function rgnv() {
  rg_prefix='rg -i --column --line-number --no-heading --sort=modified --color=always --smart-case --glob "*.md" --max-depth 1'
  local result=$(fzf --bind "start:reload($rg_prefix '' | uniq)" \
    --bind "change:reload($rg_prefix {q} | uniq || true)" \
    --bind "enter:execute(echo {} | tee /tmp/fzf_result)+abort" \
    --ansi --disabled \
    --height 80% --layout=reverse \
    --exit-0)

  if [ -s /tmp/fzf_result ]; then
    local result=$(cat /tmp/fzf_result)
    local filename=$(echo $result | cut -d':' -f1)
    local number=$(echo $result | sed 's/^[^:]*://; s/:.*//')
    rm -f /tmp/fzf_result
    nvim +$number "$filename"
  fi
}

# Ripgrep TODO items
function rgtodo() {
  rg_prefix='rg -i --column --line-number --no-heading --sort=modified --color=always --smart-case --glob "*.md" "TODO:"'
  local result=$(fzf --bind "start:reload($rg_prefix '' | uniq)" \
    --bind "change:reload($rg_prefix {q} | uniq || true)" \
    --bind "enter:execute(echo {} | tee /tmp/fzf_result)+abort" \
    --ansi --disabled \
    --height 80% --layout=reverse \
    --exit-0)

  if [ -s /tmp/fzf_result ]; then
    local result=$(cat /tmp/fzf_result)
    local filename=$(echo $result | cut -d':' -f1)
    local number=$(echo $result | sed 's/^[^:]*://; s/:.*//')
    rm -f /tmp/fzf_result
    nvim +$number "$filename"
  fi
}

# FZF + nvim
function neovim_fzf() {
  FILE=$(fzf-pre)
  if [ -n "$FILE" ]; then
    nvim +10 "$FILE"
  fi
}

# Simple vim + fzf
function vimfzf() {
  nvim "$(fzf-pre)"
}

# Vim grep with quickfix
vg() {
  local pattern="$1"
  shift
  nvim -q <(rg --vimgrep "$pattern" "$@") -c "copen"
}

# RGA (ripgrep-all) with fzf
function rga-fzf() {
  RG_PREFIX="rga --files-with-matches"
  local file
  file="$(
    FZF_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
      fzf --sort --preview="[[ ! -z {} ]] && rga --pretty --context 5 {q} {}" \
      --phony -q "$1" \
      --bind "change:reload:$RG_PREFIX {q}" \
      --preview-window="70%:wrap"
  )" &&
    echo "opening $file" &&
    {
      if command -v xdg-open &>/dev/null; then
        xdg-open "$file"
      elif command -v open &>/dev/null; then
        open "$file"
      elif command -v gio &>/dev/null; then
        gio open "$file"
      else
        echo "No open command found (xdg-open/open/gio)" >&2
        return 127
      fi
    }
}

# FZF tmux navigator — sessions >(>)> windows >(>)> panes (<: back)
function fzftmux() {
  local tmpdir=$(mktemp -d)

  # --- State ---
  printf 'sessions' > "$tmpdir/mode"
  printf '' > "$tmpdir/current_session"
  printf '' > "$tmpdir/current_window"

  # --- List: sessions ---
  cat > "$tmpdir/sessions" << 'EOF'
#!/bin/sh
tmux ls -F "#{session_name}|#{session_windows}|#{session_attached}" 2>/dev/null | while IFS='|' read -r name wins att; do
  if [ "$att" -gt 0 ]; then
    printf "\033[32m> %-20s \033[36m[%s win]  \033[33m* attached\033[0m\n" "$name" "$wins"
  else
    printf "\033[37m  %-20s \033[36m[%s win]  \033[90m  detached\033[0m\n" "$name" "$wins"
  fi
done
EOF

  # --- List: windows ---
  cat > "$tmpdir/windows" << 'EOF'
#!/bin/sh
sess="$1"
tmux list-windows -t "$sess" -F "#{window_index}|#{window_name}|#{pane_current_command}|#{pane_current_path}|#{window_active}" 2>/dev/null | while IFS='|' read -r idx wname cmd cpath active; do
  dir=$(echo "$cpath" | sed "s|^$HOME|~|")
  if [ "$active" = "1" ]; then
    printf "\033[32m> %s: %-14s \033[33m[%s]  \033[36m%s\033[0m\n" "$idx" "$wname" "$cmd" "$dir"
  else
    printf "\033[37m  %s: %-14s \033[90m[%s]  %s\033[0m\n" "$idx" "$wname" "$cmd" "$dir"
  fi
done
EOF

  # --- List: panes ---
  cat > "$tmpdir/panes" << 'EOF'
#!/bin/sh
sess="$1"; win="$2"
tmux list-panes -t "${sess}:${win}" -F "#{pane_index}|#{pane_current_command}|#{pane_current_path}|#{pane_active}|#{pane_width}x#{pane_height}" 2>/dev/null | while IFS='|' read -r idx cmd cpath active size; do
  dir=$(echo "$cpath" | sed "s|^$HOME|~|")
  if [ "$active" = "1" ]; then
    printf "\033[32m# %s  [%-12s] %-30s \033[90m%s\033[0m\n" "$idx" "$cmd" "$dir" "$size"
  else
    printf "\033[37m  %s  \033[90m[%-12s] %-30s %s\033[0m\n" "$idx" "$cmd" "$dir" "$size"
  fi
done
EOF

  # --- Universal preview (mode-aware) ---
  cat > "$tmpdir/preview" << 'PREVIEW_EOF'
#!/bin/sh
line="$1"; tmpdir="$2"
mode=$(cat "$tmpdir/mode" 2>/dev/null)

strip_ansi() { printf '%s' "$1" | sed 's/\x1b\[[0-9;]*m//g'; }

case "$mode" in
  sessions)
    clean=$(strip_ansi "$line")
    sess=$(printf '%s' "$clean" | sed 's/^[> ] *//;s/ .*//')
    [ -z "$sess" ] && exit 0
    printf "\033[35m== %s ==\033[0m\n\n" "$sess"
    tmux list-windows -t "$sess" -F "#{window_index}|#{window_name}|#{pane_current_command}|#{pane_current_path}|#{window_active}" 2>/dev/null | while IFS='|' read -r idx wname cmd cpath active; do
      dir=$(echo "$cpath" | sed "s|^$HOME|~|")
      if [ "$active" = "1" ]; then
        printf "\033[32m  > %s:\033[1m%-14s \033[33m[%s]  \033[36m%s\033[0m\n" "$idx" "$wname" "$cmd" "$dir"
      else
        printf "\033[90m    %s:\033[0m%-14s \033[90m[%s]  %s\033[0m\n" "$idx" "$wname" "$cmd" "$dir"
      fi
    done
    ;;
  windows)
    sess=$(cat "$tmpdir/current_session" 2>/dev/null | tr -d '[:space:]')
    clean=$(strip_ansi "$line")
    win=$(printf '%s' "$clean" | sed 's/^[> ] *\([0-9]*\):.*/\1/')
    [ -z "$sess" ] || [ -z "$win" ] && exit 0
    printf "\033[35m== %s:%s ==\033[0m\n\n" "$sess" "$win"
    tmux capture-pane -e -t "${sess}:${win}" -p 2>/dev/null
    ;;
  panes)
    sess=$(cat "$tmpdir/current_session" 2>/dev/null | tr -d '[:space:]')
    win=$(cat "$tmpdir/current_window" 2>/dev/null | tr -d '[:space:]')
    clean=$(strip_ansi "$line")
    pane=$(printf '%s' "$clean" | sed 's/^[# ] *\([0-9]*\) .*/\1/')
    [ -z "$pane" ] && exit 0
    printf "\033[35m== %s:%s.%s ==\033[0m\n\n" "$sess" "$win" "$pane"
    tmux capture-pane -e -t "${sess}:${win}.${pane}" -p 2>/dev/null
    ;;
esac
PREVIEW_EOF

  chmod +x "$tmpdir"/{sessions,windows,panes,preview}

  local fzf_preview_opts
  if (( ${COLUMNS:-80} < 50 )); then
    fzf_preview_opts="--preview-window=hidden"
  else
    fzf_preview_opts="--preview-window=right:55%:wrap"
  fi

  local target
  target=$(sh "$tmpdir/sessions" | \
    fzf --ansi --height 80% --layout=reverse \
      --prompt="sessions > " \
      --header=$'Enter: attach  right: drill in  left: back' \
      --preview "sh $tmpdir/preview {} $tmpdir" \
      $fzf_preview_opts \
      --bind "right:transform:
        case {fzf:prompt} in
          *panes*) ;;
          *windows*)
            sess=\$(cat $tmpdir/current_session | tr -d '[:space:]')
            win=\$(printf '%s' {} | sed 's/\x1b\[[0-9;]*m//g;s/^[> ] *\([0-9]*\):.*/\1/')
            pc=\$(tmux list-panes -t \"\${sess}:\${win}\" 2>/dev/null | wc -l | tr -d ' ')
            if [ \"\$pc\" -gt 1 ]; then
              printf '%s' \"\$win\" > $tmpdir/current_window
              printf 'panes' > $tmpdir/mode
              echo \"reload(sh $tmpdir/panes \$sess \$win)+change-prompt(\$sess:\$win panes > )\"
            fi ;;
          *sessions*)
            sess=\$(printf '%s' {} | sed 's/\x1b\[[0-9;]*m//g;s/^[> ] *//;s/ .*//')
            printf '%s' \"\$sess\" > $tmpdir/current_session
            printf 'windows' > $tmpdir/mode
            echo \"reload(sh $tmpdir/windows \$sess)+change-prompt(\$sess windows > )\" ;;
        esac" \
      --bind "left:transform:
        case {fzf:prompt} in
          *panes*)
            sess=\$(cat $tmpdir/current_session | tr -d '[:space:]')
            printf '' > $tmpdir/current_window
            printf 'windows' > $tmpdir/mode
            echo \"reload(sh $tmpdir/windows \$sess)+change-prompt(\$sess windows > )\" ;;
          *windows*)
            printf '' > $tmpdir/current_session
            printf 'sessions' > $tmpdir/mode
            echo \"reload(sh $tmpdir/sessions)+change-prompt(sessions > )\" ;;
        esac"
  )

  [[ -z "$target" ]] && { command rm -rf "$tmpdir"; return; }

  local current_sess=$(cat "$tmpdir/current_session" 2>/dev/null | tr -d '[:space:]')
  local current_win=$(cat "$tmpdir/current_window" 2>/dev/null | tr -d '[:space:]')
  local stripped=$(printf '%s' "$target" | sed 's/\x1b\[[0-9;]*m//g')

  # Auto break panes in target session when terminal is narrow (before attach)
  if (( ${COLUMNS:-80} < 50 )); then
    local bp_sess
    if [[ -n "$current_sess" ]]; then
      bp_sess="$current_sess"
    else
      bp_sess=$(printf '%s' "$stripped" | sed 's/^[> ] *//;s/ .*//')
    fi
    if [[ -n "$bp_sess" ]]; then
      for bp_win in $(tmux list-windows -t "$bp_sess" -F '#I'); do
        local bp_panes=$(tmux list-panes -t "${bp_sess}:${bp_win}" | wc -l | tr -d ' ')
        while (( bp_panes > 1 )); do
          tmux break-pane -d -s "${bp_sess}:${bp_win}.1" 2>/dev/null || break
          local bp_new=$(tmux list-panes -t "${bp_sess}:${bp_win}" | wc -l | tr -d ' ')
          (( bp_new >= bp_panes )) && break
          bp_panes=$bp_new
        done
      done
    fi
  fi

  if [[ -n "$current_win" ]]; then
    local pane=$(printf '%s' "$stripped" | sed 's/^[# ] *\([0-9]*\) .*/\1/')
    tmux attach-session -t "${current_sess}:${current_win}.${pane}"
  elif [[ -n "$current_sess" ]]; then
    local win=$(printf '%s' "$stripped" | sed 's/^[> ] *\([0-9]*\):.*/\1/')
    tmux attach-session -t "${current_sess}:${win}"
  else
    local sess=$(printf '%s' "$stripped" | sed 's/^[> ] *//;s/ .*//')
    tmux attach-session -t "$sess"
  fi
  command rm -rf "$tmpdir"
}

# FZF herdr navigator — workspaces >(>)> tabs >(>)> panes (<: back)
# herdr's workspace/tab/pane hierarchy maps to tmux's session/window/pane,
# see config.symlink/herdr/README.md. Unlike tmux, herdr's `pane focus` only
# takes a direction (no target pane id), so jumping to an exact pane does a
# geometric BFS (pathfind.py) over the tab's layout and replays the resulting
# left/right/up/down steps as real `herdr pane focus --direction` calls.
function fzfh() {
  local tmpdir=$(mktemp -d)

  # --- State ---
  printf 'workspaces' > "$tmpdir/mode"
  printf '' > "$tmpdir/current_workspace"
  printf '' > "$tmpdir/current_tab"

  # --- List: workspaces (~ tmux sessions). Each line is "display\tid". ---
  cat > "$tmpdir/workspaces" << 'EOF'
#!/bin/sh
herdr workspace list 2>/dev/null | jq -r '
  .result.workspaces[] |
  [(if .focused then "[32m> " else "[37m  " end)
    + (.label // .workspace_id)
    + "  [36m[" + (.tab_count|tostring) + "t/" + (.pane_count|tostring) + "p]"
    + (if .focused then "  [33m* focused" else "" end)
    + "  [35m" + (.agent_status // "-") + "[0m",
   .workspace_id] | @tsv'
EOF

  # --- List: tabs (~ tmux windows) ---
  cat > "$tmpdir/tabs" << 'EOF'
#!/bin/sh
ws="$1"
herdr tab list --workspace "$ws" 2>/dev/null | jq -r '
  .result.tabs[] |
  [(if .focused then "[32m> " else "[37m  " end)
    + (.number|tostring) + ": " + (.label // "")
    + "  [36m[" + (.pane_count|tostring) + "p]"
    + "  [35m" + (.agent_status // "-") + "[0m",
   .tab_id] | @tsv'
EOF

  # --- List: panes ---
  cat > "$tmpdir/panes" << 'EOF'
#!/bin/sh
ws="$1"; tab="$2"
herdr pane list --workspace "$ws" 2>/dev/null | jq -r --arg tab "$tab" --arg home "$HOME" '
  .result.panes[] | select(.tab_id == $tab) |
  [(if .focused then "[32m# " else "[37m  " end)
    + "[" + (.agent // "-") + "/" + .agent_status + "]  "
    + (.cwd | sub("^" + $home; "~"))
    + "[0m",
   .pane_id] | @tsv'
EOF

  # --- Universal preview (mode-aware; arg is the hidden id field, not display text) ---
  cat > "$tmpdir/preview" << 'PREVIEW_EOF'
#!/bin/sh
id="$1"; tmpdir="$2"
mode=$(cat "$tmpdir/mode" 2>/dev/null)
case "$mode" in
  workspaces)
    [ -z "$id" ] && exit 0
    printf "\033[35m== workspace %s ==\033[0m\n\n" "$id"
    sh "$tmpdir/tabs" "$id"
    ;;
  tabs)
    ws=$(cat "$tmpdir/current_workspace" 2>/dev/null)
    [ -z "$id" ] && exit 0
    printf "\033[35m== tab %s ==\033[0m\n\n" "$id"
    sh "$tmpdir/panes" "$ws" "$id"
    ;;
  panes)
    [ -z "$id" ] && exit 0
    printf "\033[35m== pane %s ==\033[0m\n\n" "$id"
    herdr pane read "$id" --source recent --lines 200 --format ansi 2>/dev/null
    ;;
esac
PREVIEW_EOF

  # --- Pathfinder: BFS from the currently-focused pane to a target pane id over
  # the tab's rect layout, mirroring what arrow-key nav would do. ---
  cat > "$tmpdir/pathfind.py" << 'PY'
import sys, json
from collections import deque

layout_path, start, target = sys.argv[1], sys.argv[2], sys.argv[3]
with open(layout_path) as f:
    data = json.load(f)
panes = {p["pane_id"]: p["rect"] for p in data["result"]["layout"]["panes"]}

def overlap_v(a, b):
    return a["y"] < b["y"] + b["height"] and a["y"] + a["height"] > b["y"]

def overlap_h(a, b):
    return a["x"] < b["x"] + b["width"] and a["x"] + a["width"] > b["x"]

def neighbors(pid):
    r = panes[pid]
    cands = {"right": [], "left": [], "down": [], "up": []}
    for oid, o in panes.items():
        if oid == pid:
            continue
        if o["x"] > r["x"] and overlap_v(o, r):
            cands["right"].append((o["x"], oid))
        if o["x"] < r["x"] and overlap_v(o, r):
            cands["left"].append((-o["x"], oid))
        if o["y"] > r["y"] and overlap_h(o, r):
            cands["down"].append((o["y"], oid))
        if o["y"] < r["y"] and overlap_h(o, r):
            cands["up"].append((-o["y"], oid))
    return {d: sorted(v)[0][1] for d, v in cands.items() if v}

if start == target:
    sys.exit(0)
if start not in panes or target not in panes:
    sys.exit(1)

prev = {start: None}
q = deque([start])
while q:
    cur = q.popleft()
    if cur == target:
        break
    for d, nid in neighbors(cur).items():
        if nid not in prev:
            prev[nid] = (cur, d)
            q.append(nid)

if target not in prev:
    sys.exit(1)

path, node = [], target
while prev[node] is not None:
    p, d = prev[node]
    path.append(d)
    node = p
path.reverse()
print(" ".join(path))
PY

  chmod +x "$tmpdir"/{workspaces,tabs,panes,preview}

  local fzf_preview_opts
  if (( ${COLUMNS:-80} < 50 )); then
    fzf_preview_opts="--preview-window=hidden"
  else
    fzf_preview_opts="--preview-window=right:55%:wrap"
  fi

  local target
  target=$(sh "$tmpdir/workspaces" | \
    fzf --ansi --height 80% --layout=reverse \
      --delimiter=$'\t' --with-nth=1 \
      --prompt="workspaces > " \
      --header=$'Enter: focus  right: drill in  left: back' \
      --preview "sh $tmpdir/preview {2} $tmpdir" \
      $fzf_preview_opts \
      --bind "right:transform:
        mode=\$(cat $tmpdir/mode)
        case \"\$mode\" in
          panes) ;;
          tabs)
            ws=\$(cat $tmpdir/current_workspace)
            tab={2}
            printf '%s' \"\$tab\" > $tmpdir/current_tab
            printf 'panes' > $tmpdir/mode
            echo \"reload(sh $tmpdir/panes \$ws \$tab)+change-prompt(\$tab panes > )\" ;;
          workspaces)
            wsid={2}
            printf '%s' \"\$wsid\" > $tmpdir/current_workspace
            printf 'tabs' > $tmpdir/mode
            echo \"reload(sh $tmpdir/tabs \$wsid)+change-prompt(\$wsid tabs > )\" ;;
        esac" \
      --bind "left:transform:
        mode=\$(cat $tmpdir/mode)
        case \"\$mode\" in
          panes)
            ws=\$(cat $tmpdir/current_workspace)
            printf '' > $tmpdir/current_tab
            printf 'tabs' > $tmpdir/mode
            echo \"reload(sh $tmpdir/tabs \$ws)+change-prompt(\$ws tabs > )\" ;;
          tabs)
            printf '' > $tmpdir/current_workspace
            printf 'workspaces' > $tmpdir/mode
            echo \"reload(sh $tmpdir/workspaces)+change-prompt(workspaces > )\" ;;
        esac"
  )

  [[ -z "$target" ]] && { command rm -rf "$tmpdir"; return; }

  local final_mode=$(cat "$tmpdir/mode")
  local id=$(printf '%s' "$target" | awk -F'\t' '{print $NF}')
  local ws=$(cat "$tmpdir/current_workspace" 2>/dev/null)
  local tab=$(cat "$tmpdir/current_tab" 2>/dev/null)

  case "$final_mode" in
    workspaces)
      herdr workspace focus "$id" >/dev/null
      ;;
    tabs)
      herdr workspace focus "$ws" >/dev/null
      herdr tab focus "$id" >/dev/null
      ;;
    panes)
      herdr workspace focus "$ws" >/dev/null
      herdr tab focus "$tab" >/dev/null
      local current=$(herdr pane list --workspace "$ws" 2>/dev/null | jq -r '.result.panes[] | select(.focused==true) | .pane_id')
      if [[ -n "$current" && "$current" != "$id" ]]; then
        herdr pane layout --pane "$current" > "$tmpdir/layout.json" 2>/dev/null
        local plan=$(python3 "$tmpdir/pathfind.py" "$tmpdir/layout.json" "$current" "$id" 2>/dev/null)
        local d
        for d in $plan; do
          herdr pane focus --direction "$d" >/dev/null 2>&1
        done
      fi
      ;;
  esac
  command rm -rf "$tmpdir"
}

# Delete line from file with fzf
function delete_line_with_fzf() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo "文件 $file 不存在"
    return 1
  fi
  local selected_line=$(cat "$file" | fzf)
  if [[ -n "$selected_line" ]]; then
    echo "上下文行："
    grep -C 1 -F "$selected_line" "$file" | sed "s/$selected_line/\x1b[31m&\x1b[0m/"
    local temp_file=$(mktemp)
    grep -vF "$selected_line" "$file" >"$temp_file"
    if [[ $? -eq 0 ]]; then
      mv "$temp_file" "$file"
      echo -e "\n已刪除的行：\x1b[31m$selected_line\x1b[0m"
    else
      echo "刪除過程中發生錯誤"
      rm "$temp_file"
      return 1
    fi
  else
    echo "未選定任何行"
  fi
}
