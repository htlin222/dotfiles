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
