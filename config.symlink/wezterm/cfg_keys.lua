local wezterm = require("wezterm")
-- local mytable = require("lib/mystdlib").mytable
-- local mods = require("cfg_utils").mods
local act = wezterm.action
local cfg = {}

-- AppleScript for speech-to-text dialog with auto-start Dictation
-- Opens dialog AND automatically triggers macOS Dictation (Fn twice)
local speech_to_text_applescript = [[
tell application "WezTerm"
    activate
    -- Show dialog (non-blocking display won't work, so we use a workaround)
    -- The dialog opens, then we trigger dictation after a short delay
end tell

-- Start the dialog in background and trigger dictation
tell application "System Events"
    -- Small delay to ensure dialog is ready
    delay 0.3
    -- Trigger Dictation by simulating Fn key twice (key code 63)
    key code 63
    key code 63
end tell

tell application "WezTerm"
    set dialogResult to display dialog "🎤 Dictation Active" & return & return & "Speak now! Click Insert when done." & return & "(If dictation didn't start, press Fn twice)" default answer "" buttons {"Cancel", "Insert"} default button "Insert" with title "Voice Input"
    if button returned of dialogResult is "Insert" then
        return text returned of dialogResult
    else
        return ""
    end if
end tell
]]

-- Alternative: Dialog-first approach (more reliable)
local speech_to_text_dialog_first = [[
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
local function run_speech_to_text(auto_start)
    local script = auto_start and speech_to_text_applescript or speech_to_text_dialog_first
    local handle = io.popen('osascript -e \'' .. script:gsub("'", "'\\''") .. '\' 2>/dev/null')
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
	-- Speech-to-text with AUTO-START Dictation (CMD+SHIFT+D)
	-- Opens dialog and automatically triggers macOS Dictation
	-- Requires: System Settings > Privacy & Security > Accessibility > WezTerm (enabled)
	{
		key = "d",
		mods = "CMD|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			local text = run_speech_to_text(true) -- auto_start = true
			if text and text ~= "" then
				pane:send_text(text)
			end
		end),
	},
	-- Speech-to-text MANUAL mode (CMD+CTRL+D)
	-- Opens dialog, user manually presses Fn twice to start Dictation
	{
		key = "d",
		mods = "CMD|CTRL",
		action = wezterm.action_callback(function(window, pane)
			local text = run_speech_to_text(false) -- auto_start = false
			if text and text ~= "" then
				pane:send_text(text)
			end
		end),
	},
}
return cfg
