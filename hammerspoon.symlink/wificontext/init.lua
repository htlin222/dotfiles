-- WiFi Context - WiFi 情境自動化
-- 根據連接的 WiFi 網路自動切換設定

local M = {}

-- 配置：定義你的 WiFi 網路和對應的動作
-- 請修改這些設定以符合你的環境
M.contexts = {
    -- 範例：家裡的 WiFi
    ["Home-WiFi"] = {
        name = "家裡",
        onConnect = function()
            -- 在這裡加入連接到家裡 WiFi 時要執行的動作
            -- hs.application.launchOrFocus("Music")
            -- hs.execute("open 'shortcuts://run-shortcut?name=HomeArrival'")
        end,
        onDisconnect = function()
            -- 離開家裡 WiFi 時的動作
        end,
    },

    -- 範例：辦公室的 WiFi
    ["Office-5G"] = {
        name = "辦公室",
        onConnect = function()
            -- 連接到辦公室 WiFi 時
            -- hs.application.launchOrFocus("Slack")
            -- hs.application.launchOrFocus("Calendar")
        end,
        onDisconnect = function()
            -- 離開辦公室時
        end,
    },

    -- 範例：咖啡廳等公共 WiFi (可能需要登入)
    ["Starbucks"] = {
        name = "咖啡廳",
        onConnect = function()
            -- 公共 WiFi 可能需要開啟瀏覽器登入
            -- hs.urlevent.openURL("http://captive.apple.com")
        end,
    },
}

-- 內部狀態
local watcher = nil
local lastNetwork = nil
local logger = hs.logger.new("wificontext", "info")

-- 輔助函數：取得當前 WiFi 網路名稱
local function getCurrentNetwork()
    return hs.wifi.currentNetwork()
end

-- 輔助函數：執行情境動作
local function executeContext(network, isConnect)
    local context = M.contexts[network]
    if context then
        local actionType = isConnect and "onConnect" or "onDisconnect"
        local action = context[actionType]
        if action and type(action) == "function" then
            local success, err = pcall(action)
            if not success then
                logger.e("執行 " .. network .. " 的 " .. actionType .. " 失敗: " .. tostring(err))
            end
        end
    end
end

-- WiFi 變化處理函數
local function handleWifiChange()
    local currentNetwork = getCurrentNetwork()

    -- 網路沒有變化
    if currentNetwork == lastNetwork then
        return
    end

    logger.i("WiFi 變化: " .. tostring(lastNetwork) .. " -> " .. tostring(currentNetwork))

    -- 離開舊網路
    if lastNetwork and M.contexts[lastNetwork] then
        local contextName = M.contexts[lastNetwork].name or lastNetwork
        hs.alert.show("📡 離開: " .. contextName, 2)
        executeContext(lastNetwork, false)
    end

    -- 連接新網路
    if currentNetwork then
        if M.contexts[currentNetwork] then
            local contextName = M.contexts[currentNetwork].name or currentNetwork
            hs.alert.show("📡 連接: " .. contextName, 2)
            executeContext(currentNetwork, true)
        else
            -- 未知的網路，只顯示通知
            hs.alert.show("📡 WiFi: " .. currentNetwork, 1)
        end
    else
        hs.alert.show("📡 WiFi 已斷開", 1)
    end

    lastNetwork = currentNetwork
end

-- 新增或更新情境
function M.addContext(ssid, context)
    M.contexts[ssid] = context
    return M
end

-- 移除情境
function M.removeContext(ssid)
    M.contexts[ssid] = nil
    return M
end

-- 列出所有已知的情境
function M.listContexts()
    print("=== WiFi Contexts ===")
    for ssid, context in pairs(M.contexts) do
        print(string.format("  %s: %s", ssid, context.name or "(未命名)"))
    end
    return M
end

-- 顯示當前網路
function M.showCurrentNetwork()
    local network = getCurrentNetwork()
    if network then
        local context = M.contexts[network]
        local contextName = context and context.name or "未知"
        hs.alert.show("📡 目前 WiFi: " .. network .. "\n情境: " .. contextName, 3)
    else
        hs.alert.show("📡 WiFi 未連接", 2)
    end
    return network
end

function M.start()
    if watcher then
        watcher:stop()
    end

    -- 初始化當前網路狀態
    lastNetwork = getCurrentNetwork()

    watcher = hs.wifi.watcher.new(handleWifiChange)
    watcher:start()

    hs.alert.show("✓ WiFi Context 已啟用", 2)

    -- 輸出使用說明
    print("WiFi Context 已啟動")
    print("請在 wificontext/init.lua 中設定你的 WiFi 網路")
    print("使用 require('wificontext').showCurrentNetwork() 查看當前網路")

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
