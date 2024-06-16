local wezterm = require("wezterm")
-- local mytable = require("lib/mystdlib").mytable
-- local mods = require("cfg_utils").mods
local cfg = {}
cfg.keys = {
	{
		key = "w",
		mods = "CMD",
		action = wezterm.action.CloseCurrentTab({ confirm = true }),
	},

	{
		key = "q",
		mods = "CMD",
		action = wezterm.action.CloseCurrentTab({ confirm = true }),
	},
}
return cfg
