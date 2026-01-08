require("reload")
-- require "headphone"
-- require "hotkey"
-- require("ime") -- Change input method on different app
-- require "usb"
-- require "wifi"
-- require "window"
-- require "clipboard"
-- require "statuslets"
-- require "volume"
-- require "weather"
-- require "speaker"

-- =============================================
-- 新功能模組 (2025)
-- =============================================

-- VimMode - 全系統 Vim 模式
-- 需要先安裝: git clone https://github.com/dbalatero/VimMode.spoon ~/.hammerspoon/Spoons/VimMode.spoon
require("vimmode")

-- Caffeinate Watcher - 鎖屏/解鎖/睡眠事件處理
require("caffeinate")

-- WiFi Context - 根據 WiFi 網路自動切換情境
-- 請先在 wificontext/init.lua 中設定你的 WiFi 網路
require("wificontext")

-- URL Scheme - 自訂 hammerspoon:// 協議
-- 可以從 Shortcuts、Alfred、瀏覽器等觸發
require("urlscheme")

-- 定義一個函數來執行 AppleScript
function mergeAllWindows(appName)
	local script = string.format(
		[[
        tell application "System Events"
            tell process "%s"
                click menu item "合併所有視窗" of menu "視窗" of menu bar 1
            end tell
        end tell
    ]],
		appName
	)
	hs.osascript.applescript(script)
end
function organize(appName)
	local script = string.format(
		[[
        tell application "%s" to activate
        tell application "System Events"
            tell process "%s"
                click menu item "名稱" of menu "整理方式" of menu item "顯示方式" of menu "編輯" of menu bar 1
            end tell
        end tell
    ]],
		appName,
		appName
	)
	hs.osascript.applescript(script)
end

-- 監控應用程式切換事件
hs.application.watcher
	.new(function(appName, eventType, appObject)
		if eventType == hs.application.watcher.activated then
			if appName == "Skim" or appName == "Finder" then
				mergeAllWindows(appName)
			end
			-- if appName == "Finder" then
			-- 	organize(appName)
			-- end
		end
	end)
	:start()
hs.alert.show("成功載入", 1)
