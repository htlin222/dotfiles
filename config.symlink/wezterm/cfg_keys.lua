local wezterm = require("wezterm")
-- local mytable = require("lib/mystdlib").mytable
-- local mods = require("cfg_utils").mods
local act = wezterm.action
local cfg = {}
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
		action = wezterm.action.CloseCurrentTab({ confirm = true }),
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
}
return cfg
