local wezterm = require("wezterm")
-- local mytable = require("lib/mystdlib").mytable
-- local mods = require("cfg_utils").mods
local act = wezterm.action
local cfg = {}

-- AppleScript for speech-to-text dialog
-- User can press Fn twice (or Control twice) in the dialog to activate macOS Dictation
local speech_to_text_applescript = [[
tell application "WezTerm"
    activate
    set dialogResult to display dialog "🎤 Speech to Text" & return & return & "Press Fn twice (or your Dictation key) to start voice input:" default answer "" buttons {"Cancel", "Insert"} default button "Insert" with title "Voice Input"
    if button returned of dialogResult is "Insert" then
        return text returned of dialogResult
    else
        return ""
    end if
end tell
]]

-- Execute AppleScript and return result
local function run_speech_to_text()
    local handle = io.popen('osascript -e \'' .. speech_to_text_applescript:gsub("'", "'\\''") .. '\' 2>/dev/null')
    if handle then
        local result = handle:read("*a")
        handle:close()
        -- Remove trailing newline
        return result:gsub("[\r\n]+$", "")
    end
    return ""
end

cfg.keys = {
	{
		key = "w",
		mods = "CMD",
		action = wezterm.action.CloseCurrentTab({ confirm = true }),
	},
	{
		key = "r",
		mods = "CMD|SHIFT",
		action = wezterm.action.ReloadConfiguration,
	},
	{
		key = "q",
		mods = "CMD",
		action = wezterm.action.QuitApplication,
	},
	-- Toggle between dark/light themes
	{
		key = "t",
		mods = "CMD|SHIFT",
		action = wezterm.action.EmitEvent("toggle-theme"),
	},
	-- Toggle background transparency
	{
		key = "u",
		mods = "CMD|SHIFT",
		action = wezterm.action.EmitEvent("toggle-transparency"),
	},
	{
		key = "LeftArrow",
		mods = "OPT",
		action = act.SendKey({
			key = "b",
			mods = "ALT",
		}),
	},
	{
		key = "RightArrow",
		mods = "OPT",
		action = act.SendKey({ key = "f", mods = "ALT" }),
	},
	-- Speech-to-text: Opens dialog where you can use macOS Dictation
	-- Press Fn twice (or your configured Dictation key) in the dialog to voice input
	{
		key = "d",
		mods = "CMD|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			local text = run_speech_to_text()
			if text and text ~= "" then
				pane:send_text(text)
			end
		end),
	},
}
return cfg
