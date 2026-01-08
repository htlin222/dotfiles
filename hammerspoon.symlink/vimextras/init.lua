-- VimExtras - VimMode.spoon 增強功能
-- 補足 VimMode.spoon 沒有的全系統 Vim 功能
--
-- 功能：
-- 1. 全系統 Ctrl+j/k 列表導航（模擬上下鍵）
-- 2. 全系統 Ctrl+d/u 半頁滾動
-- 3. gt/gT Tab 切換 (需要 Hyper key)
-- 4. H/L 瀏覽器歷史導航 (需要 Hyper key)
-- 5. Hyper+/ 全系統搜尋
-- 6. MenuBar 模式指示器

local M = {}

-- ============================================
-- 配置
-- ============================================
M.config = {
    -- 是否啟用各功能
    enableListNavigation = true,    -- Ctrl+j/k 列表導航
    enableScrolling = true,         -- Ctrl+d/u 半頁滾動
    enableTabSwitch = true,         -- gt/gT Tab 切換
    enableHistoryNav = true,        -- H/L 瀏覽器歷史
    enableGlobalSearch = true,      -- Hyper+/ 搜尋
    enableMenuBarIndicator = false, -- MenuBar 指示器 (需要 VimMode.spoon)

    -- 要啟用這些功能的修飾鍵
    navModifier = {"ctrl"},         -- 導航用的修飾鍵

    -- 在這些 App 中禁用 (因為它們有自己的 Vim)
    disabledApps = {
        "Code",
        "Visual Studio Code",
        "iTerm",
        "iTerm2",
        "Terminal",
        "Alacritty",
        "kitty",
        "MacVim",
        "Neovide",
        "Emacs",
        "Vim",
        "nvim",
    },
}

-- ============================================
-- 內部狀態
-- ============================================
local menubar = nil
local hotkeys = {}

-- 檢查當前 App 是否被禁用
local function isAppDisabled()
    local app = hs.application.frontmostApplication()
    if not app then return false end
    local appName = app:name()
    for _, disabled in ipairs(M.config.disabledApps) do
        if appName == disabled then
            return true
        end
    end
    return false
end

-- 條件執行：只在非禁用 App 中執行
local function safeExecute(fn)
    return function()
        if not isAppDisabled() then
            fn()
        end
    end
end

-- ============================================
-- 功能 1: Ctrl+j/k 列表導航
-- ============================================
local function setupListNavigation()
    if not M.config.enableListNavigation then return end

    -- Ctrl+j = 下
    table.insert(hotkeys, hs.hotkey.bind(M.config.navModifier, "j", safeExecute(function()
        hs.eventtap.keyStroke({}, "down", 0)
    end), nil, safeExecute(function()
        hs.eventtap.keyStroke({}, "down", 0)
    end)))

    -- Ctrl+k = 上
    table.insert(hotkeys, hs.hotkey.bind(M.config.navModifier, "k", safeExecute(function()
        hs.eventtap.keyStroke({}, "up", 0)
    end), nil, safeExecute(function()
        hs.eventtap.keyStroke({}, "up", 0)
    end)))

    -- Ctrl+h = 左
    table.insert(hotkeys, hs.hotkey.bind(M.config.navModifier, "h", safeExecute(function()
        hs.eventtap.keyStroke({}, "left", 0)
    end), nil, safeExecute(function()
        hs.eventtap.keyStroke({}, "left", 0)
    end)))

    -- Ctrl+l = 右
    table.insert(hotkeys, hs.hotkey.bind(M.config.navModifier, "l", safeExecute(function()
        hs.eventtap.keyStroke({}, "right", 0)
    end), nil, safeExecute(function()
        hs.eventtap.keyStroke({}, "right", 0)
    end)))
end

-- ============================================
-- 功能 2: Ctrl+d/u 半頁滾動
-- ============================================
local function setupScrolling()
    if not M.config.enableScrolling then return end

    -- Ctrl+d = 向下滾動
    table.insert(hotkeys, hs.hotkey.bind(M.config.navModifier, "d", safeExecute(function()
        hs.eventtap.scrollWheel({0, -5}, {}, "line")
    end), nil, safeExecute(function()
        hs.eventtap.scrollWheel({0, -5}, {}, "line")
    end)))

    -- Ctrl+u = 向上滾動
    table.insert(hotkeys, hs.hotkey.bind(M.config.navModifier, "u", safeExecute(function()
        hs.eventtap.scrollWheel({0, 5}, {}, "line")
    end), nil, safeExecute(function()
        hs.eventtap.scrollWheel({0, 5}, {}, "line")
    end)))

    -- Ctrl+f = 向下整頁
    table.insert(hotkeys, hs.hotkey.bind(M.config.navModifier, "f", safeExecute(function()
        hs.eventtap.keyStroke({}, "pagedown", 0)
    end)))

    -- Ctrl+b = 向上整頁
    table.insert(hotkeys, hs.hotkey.bind(M.config.navModifier, "b", safeExecute(function()
        hs.eventtap.keyStroke({}, "pageup", 0)
    end)))
end

-- ============================================
-- 功能 3: Tab 切換 (Ctrl+Shift+] 和 Ctrl+Shift+[)
-- ============================================
local function setupTabSwitch()
    if not M.config.enableTabSwitch then return end

    -- Ctrl+] = 下一個 Tab (gt in Vim)
    table.insert(hotkeys, hs.hotkey.bind({"ctrl", "shift"}, "]", safeExecute(function()
        -- 大多數 App 用 Cmd+Shift+] 或 Ctrl+Tab
        local app = hs.application.frontmostApplication()
        local appName = app and app:name() or ""

        if appName == "Safari" or appName == "Google Chrome" or appName == "Firefox" or appName == "Arc" then
            hs.eventtap.keyStroke({"cmd", "shift"}, "]", 0)
        else
            hs.eventtap.keyStroke({"ctrl"}, "tab", 0)
        end
    end)))

    -- Ctrl+[ = 上一個 Tab (gT in Vim)
    table.insert(hotkeys, hs.hotkey.bind({"ctrl", "shift"}, "[", safeExecute(function()
        local app = hs.application.frontmostApplication()
        local appName = app and app:name() or ""

        if appName == "Safari" or appName == "Google Chrome" or appName == "Firefox" or appName == "Arc" then
            hs.eventtap.keyStroke({"cmd", "shift"}, "[", 0)
        else
            hs.eventtap.keyStroke({"ctrl", "shift"}, "tab", 0)
        end
    end)))
end

-- ============================================
-- 功能 4: 瀏覽器歷史導航
-- ============================================
local function setupHistoryNav()
    if not M.config.enableHistoryNav then return end

    local browsers = {"Safari", "Google Chrome", "Firefox", "Arc", "Brave Browser", "Microsoft Edge"}

    local function isBrowser()
        local app = hs.application.frontmostApplication()
        if not app then return false end
        local appName = app:name()
        for _, browser in ipairs(browsers) do
            if appName == browser then
                return true
            end
        end
        return false
    end

    -- Cmd+H = 上一頁 (像 Vim 的 H 但加 Cmd 避免衝突)
    table.insert(hotkeys, hs.hotkey.bind({"cmd", "shift"}, "h", function()
        if isBrowser() then
            hs.eventtap.keyStroke({"cmd"}, "[", 0)
        end
    end))

    -- Cmd+L = 下一頁
    table.insert(hotkeys, hs.hotkey.bind({"cmd", "shift"}, "l", function()
        if isBrowser() then
            hs.eventtap.keyStroke({"cmd"}, "]", 0)
        end
    end))
end

-- ============================================
-- 功能 5: 全系統搜尋
-- ============================================
local function setupGlobalSearch()
    if not M.config.enableGlobalSearch then return end

    -- Cmd+/ = 觸發 Cmd+F 搜尋
    table.insert(hotkeys, hs.hotkey.bind({"cmd"}, "/", safeExecute(function()
        hs.eventtap.keyStroke({"cmd"}, "f", 0)
    end)))
end

-- ============================================
-- 功能 6: gg/G 跳轉 (Ctrl+gg 到頂部, Ctrl+G 到底部)
-- ============================================
local function setupJumpToEnds()
    -- Cmd+Shift+, = 跳到頂部 (像 gg)
    table.insert(hotkeys, hs.hotkey.bind({"cmd", "shift"}, ",", safeExecute(function()
        hs.eventtap.keyStroke({"cmd"}, "up", 0)
    end)))

    -- Cmd+Shift+. = 跳到底部 (像 G)
    table.insert(hotkeys, hs.hotkey.bind({"cmd", "shift"}, ".", safeExecute(function()
        hs.eventtap.keyStroke({"cmd"}, "down", 0)
    end)))
end

-- ============================================
-- 功能 7: 快速 Escape (jj 或 jk 映射到 Escape)
-- ============================================
-- 注意：這個功能 VimMode.spoon 已經有了，這裡提供一個備選方案
local function setupQuickEscape()
    -- 這個用 eventtap 實現，讓 jk 快速連按變成 Escape
    -- 但可能會跟 VimMode.spoon 衝突，所以預設不啟用
end

-- ============================================
-- 初始化
-- ============================================
function M.init()
    -- 清理舊的 hotkeys
    for _, hk in ipairs(hotkeys) do
        hk:delete()
    end
    hotkeys = {}

    -- 設置各功能
    setupListNavigation()
    setupScrolling()
    setupTabSwitch()
    setupHistoryNav()
    setupGlobalSearch()
    setupJumpToEnds()

    hs.alert.show("✓ VimExtras 已啟用", 2)

    -- 輸出使用說明
    print("=== VimExtras 快捷鍵 ===")
    print("Ctrl + h/j/k/l  : 方向鍵 (列表/選單導航)")
    print("Ctrl + d/u      : 半頁滾動")
    print("Ctrl + f/b      : 整頁滾動")
    print("Ctrl+Shift + ]  : 下一個 Tab (gt)")
    print("Ctrl+Shift + [  : 上一個 Tab (gT)")
    print("Cmd+Shift + H   : 瀏覽器上一頁")
    print("Cmd+Shift + L   : 瀏覽器下一頁")
    print("Cmd + /         : 搜尋 (Cmd+F)")
    print("Cmd+Shift + ,   : 跳到頂部 (gg)")
    print("Cmd+Shift + .   : 跳到底部 (G)")

    return M
end

-- 停止
function M.stop()
    for _, hk in ipairs(hotkeys) do
        hk:delete()
    end
    hotkeys = {}

    if menubar then
        menubar:delete()
        menubar = nil
    end

    return M
end

-- 禁用特定 App
function M.disableForApp(appName)
    table.insert(M.config.disabledApps, appName)
    return M
end

-- 自動初始化
M.init()

return M
