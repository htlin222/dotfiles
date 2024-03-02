local wezterm = require("wezterm")
local mytable = require("lib/mystdlib").mytable
local mods = require("cfg_utils").mods

local act = wezterm.action
local act_callback = wezterm.action_callback

local cfg = {}

-- Helper for keybind definition
local function keybind(mods, keys, action)
	local keys = (type(keys) == "table") and keys or { keys }
	local mods = mods
	local binds = {}
	for _, key in ipairs(keys) do
		table.insert(binds, { mods = mods, key = key, action = action })
	end
	return binds
end

cfg.disable_default_key_bindings = true

cfg.key_tables = {}
local function define_and_activate_keytable(spec)
	-- Flatten keys, and define the Key Table
	cfg.key_tables[spec.name] = mytable.flatten_list(spec.keys)

	-- Setup & return activation key bind
	local activation_opts = spec.activation or {}
	activation_opts.name = spec.name
	return act.ActivateKeyTable(activation_opts)
end

-- Raw key codes are hardware & OS/WM dependent, so they're not really portable..
-- https://wezfurlong.org/wezterm/config/keys.html#raw-key-assignments
local known_raw_keys_by_os = {
	["^"] = { linux = "raw:34", win = nil },
}
local function get_raw_key(keysym)
	local target_triple_to_os = {
		["x86_64-pc-windows-msvc"] = "windows",
		["x86_64-unknown-linux-gnu"] = "linux",
	}
	local os = target_triple_to_os[wezterm.target_triple]
	assert(
		os,
		"Unknown os for getting raw key keysym:"
			.. tostring(keysym)
			.. " (target_triple:"
			.. tostring(wezterm.target_triple)
			.. ")"
	)
	local key_by_os = known_raw_keys_by_os[keysym]
	assert(key_by_os, "Unknown keysym:" .. tostring(keysym))
	local key_raw = key_by_os[os]
	assert(key_raw, "Unknown raw key for keysym:" .. tostring(keysym) .. " os:" .. tostring(os))
	return key_raw
end

-- NOTE: About SHIFT and the keybind definition:
-- * For bindings with SHIFT and a letter, the `key` field (the letter)
--   can be lowercase and the mods should NOT contain 'SHIFT'.
-- * For bindings with SHIFT and something else, mod should contain SHIFT,
--   and key should be the shifted key that is going to reach the terminal.
--   (based on the keyboard-layout)
cfg.keys = {
	-- Remap C-Backspace to C-w everywhere
	keybind(mods.C, "Backspace", act.SendKey({ mods = mods.C, key = "w" })),
	-- Remap A-^/$ to Home/End globally
	-- NOTE: Mapped via raw key code to bypass waiting for dead key handling (like ^e -> ê)
	-- (could also be done at system/desktop level, but this is a good level for all terminal apps)
	keybind(mods.A, get_raw_key("^"), act.SendKey({ key = "Home" })),
	keybind(mods.A, "$", act.SendKey({ key = "End" })),
	-- Force map `Alt-^` itself to terminal program (like neovim!).
	-- NOTE: Mapped via raw key code to bypass waiting for dead key handling (like ^e -> ê)
	--keybind(mods.A, get_raw_key("^"), act.SendKey{mods=mods.A, key="^"}),

	keybind(mods.S, "PageUp", act.ScrollByPage(-1)),
	keybind(mods.S, "PageDown", act.ScrollByPage(1)),

	-- keybind(mods.CS, "r", act.ReloadConfiguration),
	keybind(mods.CS, "r", act.EmitEvent("my-reload-config-with-notif")),

	keybind(mods.CS, "l", act.ClearScrollback("ScrollbackAndViewport")),
	keybind(mods.CS, " ", act.QuickSelect),
	keybind(mods.CA, " ", act.QuickSelect), -- note: eats a valid term input
	keybind(mods.CS, "d", act.ShowDebugOverlay),
	keybind(mods.CS, "y", act.ActivateCopyMode),
	-- note: last search is now prefilled, may need to clear it first with Ctrl-u
	keybind(mods.CS, "f", act.Search({ CaseInSensitiveString = "" })),

	-- Copy/Paste to/from Clipboard
	keybind(mods.CS, "c", act.CopyTo("ClipboardAndPrimarySelection")),
	keybind(mods.CS, "v", act.PasteFrom("Clipboard")),
	keybind(mods.CA, "v", act.PasteFrom("Clipboard")), -- note: eats a valid term input
	-- Paste from PrimarySelection
	keybind(mods.S, "Insert", act.PasteFrom("PrimarySelection")),

	-- Smart copy with Alt-c:
	-- - If active selection, will copy it to Clipboard & Primary
	-- - If NO selection, sends Alt-c to the running program (which may do a copy in context)
	keybind(
		mods.A,
		"c",
		act_callback(function(win, pane)
			local has_selection = win:get_selection_text_for_pane(pane) ~= ""
			if has_selection then
				win:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)
			else
				win:perform_action(act.SendKey({ mods = mods.A, key = "c" }), pane)
			end
		end)
	),

	-- Tabs
	keybind(mods.CS, "t", act.SpawnTab("DefaultDomain")),
	keybind(mods.C, "Tab", act.ActivateTabRelative(1)),
	keybind(mods.CS, "Tab", act.ActivateTabRelative(-1)),
	-- keybind(mods.CS, "w", act.CloseCurrentTab{confirm=false}),

	keybind(mods.CS, "x", act.ShowLauncher),
	keybind(mods.CS, "p", act.ActivateCommandPalette),
	keybind(mods.CS, "c", act.CharSelect),

	-- Font size
	keybind(mods.C, "0", act.ResetFontSize), -- Ctrl-Shift-0
	keybind(mods.C, "+", act.IncreaseFontSize), -- Ctrl-Shift-+ (key with +)
	keybind(mods.C, "6", act.DecreaseFontSize), -- Ctrl-Shift-- (key with -)
	-- On Windows, the Shift modifier seems to not be removed for these ^ shifted keys,
	-- so I may have to add SHIFT.

	-- Toggle font ligatures
	keybind(
		mods.CS,
		"g",
		act_callback(function(win, _)
			local overrides = win:get_config_overrides() or {}
			if not overrides.harfbuzz_features then
				-- If we haven't overriden it yet, then override with ligatures disabled
				overrides.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
			else
				-- else we did already, and we should disable the override now
				overrides.harfbuzz_features = nil
			end
			win:set_config_overrides(overrides)
		end)
	),

	keybind(
		mods.CS,
		"Space",
		define_and_activate_keytable({
			name = "Leader",
			-- Make this layer volatile, easily dismissed
			activation = { one_shot = true, until_unknown = true },
			keys = {
				keybind(mods._, "Escape", act.PopKeyTable),

				keybind(mods.C, "v", act.PasteFrom("Clipboard")),

				keybind(
					mods._,
					"f",
					define_and_activate_keytable({
						name = "font size",
						activation = { one_shot = false },
						keys = {
							keybind(mods._, "Escape", act.PopKeyTable),
							keybind(mods._, "j", act.DecreaseFontSize),
							keybind(mods._, "k", act.IncreaseFontSize),
							keybind(mods._, "r", act.ResetFontSize),
						},
					})
				),

				-- Key Table: Panes Management
				keybind(
					mods.CS,
					"p",
					define_and_activate_keytable({
						name = "my-panes-management",
						activation = { one_shot = false },
						keys = {
							keybind(mods._, "Escape", act.PopKeyTable),
							keybind(mods.CS, "p", act.PopKeyTable),

							-- Create
							keybind(mods.CSA, { "h", "LeftArrow" }, act.SplitPane({ direction = "Left" })),
							keybind(mods.CSA, { "j", "DownArrow" }, act.SplitPane({ direction = "Down" })),
							keybind(mods.CSA, { "k", "UpArrow" }, act.SplitPane({ direction = "Up" })),
							keybind(mods.CSA, { "l", "RightArrow" }, act.SplitPane({ direction = "Right" })),
							-- Destroy
							keybind(mods.CS, "d", act.CloseCurrentPane({ confirm = true })),

							-- Navigation
							keybind(mods.CS, { "h", "LeftArrow" }, act.ActivatePaneDirection("Left")),
							keybind(mods.CS, { "j", "DownArrow" }, act.ActivatePaneDirection("Down")),
							keybind(mods.CS, { "k", "UpArrow" }, act.ActivatePaneDirection("Up")),
							keybind(mods.CS, { "l", "RightArrow" }, act.ActivatePaneDirection("Right")),
							keybind(mods.CS, "Space", act.PaneSelect({ mode = "Activate" })),

							-- Manipulation
							keybind(mods.CS, "s", act.PaneSelect({ mode = "SwapWithActive" })),
							keybind(mods.CS, "z", act.TogglePaneZoomState),
						},
					})
				),
			},
		})
	),
}

cfg.key_tables.copy_mode = mytable.flatten_list({
	wezterm.gui.default_key_tables().copy_mode, -- extend default 'copy_mode' table
	keybind(mods._, "i", act.CopyMode("Close")),
})

-- Events related to config reloading
wezterm.on("my-reload-config-with-notif", function(win, pane)
	wezterm.GLOBAL.want_reload_notification = true
	win:perform_action(act.ReloadConfiguration, pane)
	-- Will trigger the builtin `window-config-reloaded` event, the notification is wired on
	-- that event, to make sure only a _valid_ config reload will display it.
end)
wezterm.on("window-config-reloaded", function(win, _)
	if wezterm.GLOBAL.want_reload_notification then
		win:toast_notification("wezterm", "Config successfully reloaded!", nil, 1000)
		wezterm.GLOBAL.want_reload_notification = false
	end
end)

-- To simplify config composability, `cfg.keys` is (initially) a
-- nested list of (bind or list of (bind or ...)), so we must
-- flatten the list to have a list of bind.
cfg.keys = mytable.flatten_list(cfg.keys)
cfg.window_close_confirmation = "AlwaysPrompt"
cfg.keys = {
	{
		key = "w",
		mods = "CMD",
		action = wezterm.action.CloseCurrentTab({ confirm = true }),
	},
}

return cfg
