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

-- App 切換追蹤（存到 /tmp/app-idle.tsv）
appSwitchLog = {}
local logFile = "/tmp/app-idle.tsv"
local appSwitchDirty = true

-- lightweight flush: only writes idle/switch data (no top, instant)
function flushAppLogFast()
	local now = os.time()
	local f = io.open(logFile, "w")
	if not f then return end
	f:write("PID\tAPP\tIDLE\tCOUNT\tLAST_SEEN\tRAM_MB\n")

	local apps = hs.application.runningApplications()
	local seen = {}
	for _, app in ipairs(apps) do
		local ok, name, pid, kind = pcall(function()
			return app:name(), app:pid(), app:kind()
		end)
		if ok and name and pid and kind and kind == 1 then
			local info = appSwitchLog[name]
			local lastSeen = info and info.lastSeen or 0
			local count = info and info.count or 0
			local idle = lastSeen > 0 and (now - lastSeen) or -1
			if not seen[name] then
				f:write(string.format("%d\t%s\t%d\t%d\t%s\t0\n", pid, name, idle, count,
					lastSeen > 0 and os.date("%Y-%m-%d %H:%M:%S", lastSeen) or "never"))
				seen[name] = true
			end
		end
	end
	f:close()
end

-- 監控應用程式切換事件
hs.application.watcher
	.new(function(appName, eventType, appObject)
		if eventType == hs.application.watcher.activated then
			-- 記錄切換
			if appName then
				if not appSwitchLog[appName] then
					appSwitchLog[appName] = { count = 0, lastSeen = os.time() }
				end
				appSwitchLog[appName].lastSeen = os.time()
				appSwitchLog[appName].count = appSwitchLog[appName].count + 1
			end
			flushAppLogFast()

			if appName == "Skim" or appName == "Finder" then
				mergeAllWindows(appName)
			end
		end
	end)
	:start()

-- 啟動時先 flush 一次
flushAppLogFast()
hs.alert.show("成功載入", 1)
