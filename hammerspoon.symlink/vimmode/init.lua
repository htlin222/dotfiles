-- VimMode 載入器
-- 需要先安裝 VimMode.spoon:
--   git clone https://github.com/dbalatero/VimMode.spoon ~/.hammerspoon/Spoons/VimMode.spoon

local M = {}

-- 檢查 VimMode.spoon 是否已安裝
local function spoonExists()
    local spoonPath = hs.spoons.resourcePath("VimMode")
    if spoonPath then return true end

    -- 檢查常見位置
    local paths = {
        os.getenv("HOME") .. "/.hammerspoon/Spoons/VimMode.spoon",
        hs.configdir .. "/Spoons/VimMode.spoon",
    }
    for _, path in ipairs(paths) do
        local f = io.open(path .. "/init.lua", "r")
        if f then
            f:close()
            return true
        end
    end
    return false
end

function M.init()
    if not spoonExists() then
        hs.alert.show("⚠️ VimMode.spoon 未安裝\n請執行安裝指令", 5)
        print("VimMode.spoon 未安裝。請執行:")
        print("  git clone https://github.com/dbalatero/VimMode.spoon ~/.hammerspoon/Spoons/VimMode.spoon")
        return nil
    end

    local VimMode = hs.loadSpoon('VimMode')
    local vim = VimMode:new()

    -- 設定進入 Normal 模式的快捷鍵序列
    vim:enterWithSequence('jk')

    -- 在這些 App 中禁用 VimMode (因為它們有自己的 Vim 模式)
    vim:disableForApp('Code')
    vim:disableForApp('Visual Studio Code')
    vim:disableForApp('iTerm')
    vim:disableForApp('iTerm2')
    vim:disableForApp('Terminal')
    vim:disableForApp('Alacritty')
    vim:disableForApp('kitty')
    vim:disableForApp('MacVim')
    vim:disableForApp('Neovide')
    vim:disableForApp('Emacs')
    vim:disableForApp('Obsidian')  -- Obsidian 有自己的 Vim 模式

    -- 顯示模式指示器
    vim:shouldShowAlertInNormalMode(true)

    hs.alert.show("✓ VimMode 已啟用 (jk 進入)", 2)

    return vim
end

return M
