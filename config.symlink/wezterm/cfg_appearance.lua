local wezterm = require("wezterm")
local themes = require("cfg_themes")

local cfg = {}

cfg.hide_tab_bar_if_only_one_tab = true
cfg.window_decorations = "RESIZE"
cfg.front_end = "WebGpu"

-- Background opacity settings
cfg.window_background_opacity = 1.0 -- Default: opaque
cfg.macos_window_background_blur = 20 -- Blur effect when transparent (macOS only)

-- Toggle transparency event handler
wezterm.on("toggle-transparency", function(window, _)
	local overrides = window:get_config_overrides() or {}
	local current_opacity = overrides.window_background_opacity or 1.0

	-- Toggle between opaque (1.0) and transparent (0.3)
	local new_opacity = current_opacity < 1.0 and 1.0 or 0.3
	overrides.window_background_opacity = new_opacity

	window:set_config_overrides(overrides)
	wezterm.log_info("Transparency: " .. (new_opacity < 1.0 and "ON" or "OFF"))
end)

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

-- Use theme system for colors (default: dark theme)
-- Toggle with CMD+SHIFT+T
cfg.colors = themes.get_current_colors()

-- Setup theme switching event handler
themes.setup_theme_switching()

return cfg
