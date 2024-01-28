print("==================================================")
-- require "headphone"
-- require "hotkey"
require("ime") -- Change input method on different app
require("reload")
-- require "usb"
-- require "wifi"
-- require "window"
-- require "clipboard"
-- require "statuslets"
-- require "volume"
-- require "weather"
-- require "speaker"

-- Private use
if hs.host.localizedName() == "kaboom的MacBook Pro" then
	require("autoscript")
end

hs.alert.show("Hammerspoon Config Loaded", 1)
