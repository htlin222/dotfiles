-- Theme management for WezTerm
-- Available themes: "dark" (bew_colors), "light" (latte)

local wezterm = require("wezterm")

local M = {}

-- Available themes
M.themes = {
	dark = require("cfg_bew_colors"),
	light = require("cfg_latte"),
}

-- Theme order for cycling
M.theme_order = { "dark", "light" }

-- Get current theme name from GLOBAL state, default to "dark"
function M.get_current_theme_name()
	return wezterm.GLOBAL.current_theme or "dark"
end

-- Get the next theme in the cycle
function M.get_next_theme_name()
	local current = M.get_current_theme_name()
	for i, name in ipairs(M.theme_order) do
		if name == current then
			local next_index = (i % #M.theme_order) + 1
			return M.theme_order[next_index]
		end
	end
	return M.theme_order[1]
end

-- Get current theme colors
function M.get_current_colors()
	return M.themes[M.get_current_theme_name()]
end

-- Setup theme switching event handler
function M.setup_theme_switching()
	wezterm.on("toggle-theme", function(window, _)
		local next_theme = M.get_next_theme_name()
		wezterm.GLOBAL.current_theme = next_theme

		local overrides = window:get_config_overrides() or {}
		overrides.colors = M.themes[next_theme]

		window:set_config_overrides(overrides)

		-- Show notification
		window:toast_notification("WezTerm", "Theme: " .. next_theme, nil, 2000)
	end)
end

return M
