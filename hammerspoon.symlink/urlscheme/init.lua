-- URL Scheme - 自訂 hammerspoon:// 協議
-- 讓其他 App、Shortcuts、Alfred 可以觸發 Hammerspoon 動作
--
-- 使用方式:
--   在瀏覽器或 Shortcuts 中開啟:
--   hammerspoon://reload
--   hammerspoon://alert?message=Hello
--   hammerspoon://focus-work
--   hammerspoon://run?command=yourCommand&arg1=value1

local M = {}

-- 配置
M.config = {
    -- 是否顯示 URL 執行的 alert
    showAlerts = true,

    -- 是否記錄到 console
    enableLogging = true,
}

local logger = hs.logger.new("urlscheme", "info")

-- 預設的 URL handlers
M.handlers = {
    -- 重新載入配置
    ["reload"] = function(params)
        hs.reload()
    end,

    -- 顯示 alert
    ["alert"] = function(params)
        local message = params.message or params.msg or "Hammerspoon"
        local duration = tonumber(params.duration) or 2
        hs.alert.show(message, duration)
    end,

    -- 開啟指定 App
    ["open"] = function(params)
        local app = params.app or params.name
        if app then
            hs.application.launchOrFocus(app)
            return true, "已開啟 " .. app
        else
            return false, "請提供 app 參數"
        end
    end,

    -- 切換 App (如果已開啟則隱藏)
    ["toggle"] = function(params)
        local appName = params.app or params.name
        if not appName then
            return false, "請提供 app 參數"
        end

        local app = hs.application.get(appName)
        if app then
            if app:isFrontmost() then
                app:hide()
                return true, appName .. " 已隱藏"
            else
                app:activate()
                return true, appName .. " 已啟動"
            end
        else
            hs.application.launchOrFocus(appName)
            return true, appName .. " 已開啟"
        end
    end,

    -- 專注模式 - 範例
    ["focus-work"] = function(params)
        local duration = tonumber(params.duration) or 25 -- 預設 25 分鐘

        -- 關閉干擾的 App
        local distractingApps = {"Slack", "Discord", "Messages", "Twitter"}
        for _, appName in ipairs(distractingApps) do
            local app = hs.application.get(appName)
            if app then app:kill() end
        end

        -- 開啟專注用的 App
        hs.application.launchOrFocus("Code")

        -- 設定計時器提醒
        hs.timer.doAfter(duration * 60, function()
            hs.alert.show("⏰ 專注時間結束！\n休息一下吧", 5)
            hs.sound.getByName("Glass"):play()
        end)

        hs.alert.show("🎯 專注模式\n" .. duration .. " 分鐘", 3)
        return true, "專注模式已啟動"
    end,

    -- 休息模式
    ["take-break"] = function(params)
        local duration = tonumber(params.duration) or 5 -- 預設 5 分鐘

        -- 開啟放鬆用的 App
        -- hs.application.launchOrFocus("Music")

        hs.timer.doAfter(duration * 60, function()
            hs.alert.show("⏰ 休息時間結束！\n繼續工作吧", 5)
            hs.sound.getByName("Glass"):play()
        end)

        hs.alert.show("☕ 休息模式\n" .. duration .. " 分鐘", 3)
        return true, "休息模式已啟動"
    end,

    -- 視窗管理
    ["window"] = function(params)
        local action = params.action or params.a
        local win = hs.window.focusedWindow()

        if not win then
            return false, "沒有焦點視窗"
        end

        if action == "maximize" or action == "max" then
            win:maximize()
        elseif action == "left" then
            win:move(hs.layout.left50)
        elseif action == "right" then
            win:move(hs.layout.right50)
        elseif action == "center" then
            win:centerOnScreen()
        elseif action == "fullscreen" or action == "fs" then
            win:setFullScreen(not win:isFullScreen())
        else
            return false, "未知的視窗動作: " .. tostring(action)
        end

        return true, "視窗動作: " .. action
    end,

    -- 執行 shell 命令 (請小心使用)
    ["shell"] = function(params)
        local cmd = params.cmd or params.command
        if not cmd then
            return false, "請提供 cmd 參數"
        end

        -- 安全檢查：只允許特定命令
        local allowedPrefixes = {"open ", "osascript "}
        local allowed = false
        for _, prefix in ipairs(allowedPrefixes) do
            if cmd:sub(1, #prefix) == prefix then
                allowed = true
                break
            end
        end

        if not allowed then
            return false, "不允許的命令"
        end

        local output, status = hs.execute(cmd)
        return status, output
    end,

    -- 播放/暫停音樂
    ["music"] = function(params)
        local action = params.action or "toggle"

        if action == "play" then
            hs.spotify.play()
            hs.itunes.play()
        elseif action == "pause" then
            hs.spotify.pause()
            hs.itunes.pause()
        elseif action == "toggle" then
            hs.spotify.playpause()
            hs.itunes.playpause()
        elseif action == "next" then
            hs.spotify.next()
            hs.itunes.next()
        elseif action == "prev" or action == "previous" then
            hs.spotify.previous()
            hs.itunes.previous()
        end

        return true, "音樂: " .. action
    end,

    -- 顯示已註冊的 handlers
    ["help"] = function(params)
        local handlers = {}
        for name, _ in pairs(M.handlers) do
            table.insert(handlers, name)
        end
        table.sort(handlers)

        local msg = "可用的 URL handlers:\n" .. table.concat(handlers, ", ")
        hs.alert.show(msg, 5)
        print(msg)
        return true, msg
    end,
}

-- 解析 URL 參數
local function parseParams(query)
    local params = {}
    if not query or query == "" then
        return params
    end

    for pair in query:gmatch("[^&]+") do
        local key, value = pair:match("([^=]+)=?(.*)")
        if key then
            -- URL decode
            key = key:gsub("%%(%x%x)", function(h)
                return string.char(tonumber(h, 16))
            end)
            value = value:gsub("%%(%x%x)", function(h)
                return string.char(tonumber(h, 16))
            end)
            params[key] = value
        end
    end

    return params
end

-- 主要的 URL 事件處理函數
local function handleURL(eventName, params)
    if M.config.enableLogging then
        logger.i("收到 URL 事件: " .. eventName)
        for k, v in pairs(params or {}) do
            logger.i("  參數: " .. k .. " = " .. tostring(v))
        end
    end

    local handler = M.handlers[eventName]
    if handler then
        local success, result = pcall(handler, params)
        if not success then
            logger.e("Handler 錯誤: " .. tostring(result))
            if M.config.showAlerts then
                hs.alert.show("❌ 錯誤: " .. tostring(result), 3)
            end
        elseif M.config.enableLogging then
            logger.i("Handler 結果: " .. tostring(result))
        end
    else
        local msg = "未知的 URL handler: " .. eventName
        logger.w(msg)
        if M.config.showAlerts then
            hs.alert.show("⚠️ " .. msg, 2)
        end
    end
end

-- 新增自訂 handler
function M.addHandler(name, handler)
    if type(handler) ~= "function" then
        error("Handler 必須是函數")
    end
    M.handlers[name] = handler
    hs.urlevent.bind(name, handleURL)
    return M
end

-- 移除 handler
function M.removeHandler(name)
    M.handlers[name] = nil
    -- 注意：hs.urlevent 沒有 unbind 方法
    return M
end

-- 初始化
function M.init()
    -- 綁定所有預設 handlers
    for name, _ in pairs(M.handlers) do
        hs.urlevent.bind(name, handleURL)
    end

    hs.alert.show("✓ URL Scheme 已啟用", 2)

    -- 輸出使用說明
    print("=== URL Scheme 已啟動 ===")
    print("使用方式: hammerspoon://[command]?[params]")
    print("範例:")
    print("  hammerspoon://reload")
    print("  hammerspoon://alert?message=Hello&duration=3")
    print("  hammerspoon://open?app=Finder")
    print("  hammerspoon://focus-work?duration=25")
    print("  hammerspoon://window?action=maximize")
    print("  hammerspoon://help")
    print("")
    print("在終端機測試:")
    print("  open 'hammerspoon://help'")

    return M
end

-- 自動初始化
M.init()

return M
