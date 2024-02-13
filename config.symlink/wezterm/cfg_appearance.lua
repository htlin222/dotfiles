local cfg = {}

cfg.hide_tab_bar_if_only_one_tab = true

-- Pad window to avoid the content to be too close to the border,
-- so it's easier to see and select.
-- Acceptable values are SteadyBlock, BlinkingBlock, SteadyUnderline, BlinkingUnderline, SteadyBar, and BlinkingBar.
cfg.default_cursor_style = "SteadyUnderline"
cfg.window_padding = {
	left = 3,
	right = 3,
	top = 3,
	bottom = 3,
}

cfg.inactive_pane_hsb = {
	-- NOTE: these values are multipliers, applied on normal pane values
	saturation = 0.9,
	brightness = 0.6,
}

cfg.colors = require("cfg_bew_colors")

return cfg
