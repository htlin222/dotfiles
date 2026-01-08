-- Caffeinate Watcher - 智慧電源事件處理
-- 在鎖屏/解鎖/睡眠/喚醒時自動執行動作

local M = {}

-- 配置：根據你的需求修改這些設定
M.config = {
    -- 鎖屏時要暫停的音樂 App
    musicApps = {"Spotify", "Music", "iTunes"},

    -- 解鎖時要啟動的 App (設為 nil 則不自動啟動)
    appsOnUnlock = nil, -- 例如: {"Slack", "Mail"}

    -- 是否在解鎖時顯示歡迎訊息
    showWelcomeMessage = true,

    -- 是否記錄事件到 console
    enableLogging = true,
}

-- 內部狀態
local watcher = nil
local logger = hs.logger.new("caffeinate", "info")

-- 輔助函數：暫停音樂
local function pauseMusic()
    for _, appName in ipairs(M.config.musicApps) do
        local app = hs.application.get(appName)
        if app and app:isRunning() then
            -- 嘗試用 AppleScript 暫停
            if appName == "Spotify" then
                hs.spotify.pause()
            elseif appName == "Music" or appName == "iTunes" then
                hs.itunes.pause()
            end
        end
    end
end

-- 輔助函數：取得當前時間的問候語
local function getGreeting()
    local hour = tonumber(os.date("%H"))
    if hour < 6 then
        return "夜深了 🌙"
    elseif hour < 12 then
        return "早安 ☀️"
    elseif hour < 18 then
        return "午安 🌤"
    else
        return "晚安 🌆"
    end
end

-- 輔助函數：格式化時間差
local function formatDuration(seconds)
    if seconds < 60 then
        return string.format("%d 秒", seconds)
    elseif seconds < 3600 then
        return string.format("%d 分鐘", math.floor(seconds / 60))
    else
        local hours = math.floor(seconds / 3600)
        local mins = math.floor((seconds % 3600) / 60)
        return string.format("%d 小時 %d 分鐘", hours, mins)
    end
end

-- 記錄鎖屏時間
local lockTime = nil

-- 事件處理函數
local function handleCaffeinateEvent(event)
    local eventNames = {
        [hs.caffeinate.watcher.screensDidLock] = "screensDidLock",
        [hs.caffeinate.watcher.screensDidUnlock] = "screensDidUnlock",
        [hs.caffeinate.watcher.screensDidSleep] = "screensDidSleep",
        [hs.caffeinate.watcher.screensDidWake] = "screensDidWake",
        [hs.caffeinate.watcher.systemDidWake] = "systemDidWake",
        [hs.caffeinate.watcher.systemWillSleep] = "systemWillSleep",
        [hs.caffeinate.watcher.systemWillPowerOff] = "systemWillPowerOff",
        [hs.caffeinate.watcher.sessionDidBecomeActive] = "sessionDidBecomeActive",
        [hs.caffeinate.watcher.sessionDidResignActive] = "sessionDidResignActive",
    }

    if M.config.enableLogging then
        logger.i("Caffeinate event: " .. (eventNames[event] or tostring(event)))
    end

    -- 螢幕鎖定
    if event == hs.caffeinate.watcher.screensDidLock then
        lockTime = os.time()
        pauseMusic()
        if M.config.enableLogging then
            logger.i("螢幕已鎖定，音樂已暫停")
        end

    -- 螢幕解鎖
    elseif event == hs.caffeinate.watcher.screensDidUnlock then
        if M.config.showWelcomeMessage then
            local msg = getGreeting()
            if lockTime then
                local duration = os.time() - lockTime
                if duration > 60 then -- 只有鎖定超過 1 分鐘才顯示時長
                    msg = msg .. "\n離開了 " .. formatDuration(duration)
                end
            end
            hs.alert.show(msg, 2)
        end

        -- 啟動指定的 App
        if M.config.appsOnUnlock then
            for _, appName in ipairs(M.config.appsOnUnlock) do
                hs.application.launchOrFocus(appName)
            end
        end

        lockTime = nil

    -- 系統即將睡眠
    elseif event == hs.caffeinate.watcher.systemWillSleep then
        pauseMusic()
        if M.config.enableLogging then
            logger.i("系統即將睡眠")
        end

    -- 系統喚醒
    elseif event == hs.caffeinate.watcher.systemDidWake then
        if M.config.enableLogging then
            logger.i("系統已喚醒")
        end
    end
end

function M.start()
    if watcher then
        watcher:stop()
    end
    watcher = hs.caffeinate.watcher.new(handleCaffeinateEvent)
    watcher:start()
    hs.alert.show("✓ Caffeinate Watcher 已啟用", 2)
    return M
end

function M.stop()
    if watcher then
        watcher:stop()
        watcher = nil
    end
    return M
end

-- 自動啟動
M.start()

return M
