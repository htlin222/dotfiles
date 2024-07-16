local wezterm = require("wezterm")

local cfg = {}

-- Disable annoying default behaviors
cfg.adjust_window_size_when_changing_font_size = false
-- that one was opening a separate win on first unknown glyph, stealing windows focus (!!)
cfg.warn_about_missing_glyphs = false

cfg.font_size = 18.0
cfg.cell_width = 1.0
cfg.window_decorations = "RESIZE"

-- Makes FontAwesome's double-width glyphs display properly!
cfg.allow_square_glyphs_to_overflow_width = "WhenFollowedBySpace"
-- cfg.allow_square_glyphs_to_overflow_width = "Never"

-- Additional font directory (necessary to find FontAwesome font!)
cfg.font_dirs = { "fonts" } -- relative to main config file

local function font_with_fallback(font_family)
	-- family names, not file names
	return wezterm.font_with_fallback({
		font_family,
		"Font Awesome 6 Free Solid", -- nice double-spaced symbols!
		{ family = "jf open 粉圓 2.0" },
	})
end

local function font_and_rules_for_jetbrains()
	-- Use a _very slightly_ lighter variant, so that regular bold really stand out
	local font = font_with_fallback("JetBrainsMono NF Medium")
	local font_rules = {
		{
			italic = true,
			font = font_with_fallback("JetBrainsMono NF Medium Italic"),
		},
		{
			italic = true,
			intensity = "Bold",
			font = font_with_fallback("JetBrainsMono NF SemiBold Italic"),
		},
		{
			intensity = "Bold",
			font = font_with_fallback("JetBrainsMono NFM ExtraBold"),
		},
	}
	return font, font_rules
end

-- FIXME (<- this is an example of bolded text)
-- 0 1 2 3 4 5 6 7 8 9
-- Some ligatures: != <-> <-  -> ----> => ==> ===> -- --- /../;;/ #{}
--  <> <!-- --> ->> --> <= >= ++ == === := a::b::c a&&b a||b

cfg.font, cfg.font_rules = font_and_rules_for_jetbrains()

-- Enable various OpenType features
-- See https://docs.microsoft.com/en-us/typography/opentype/spec/featurelist
cfg.harfbuzz_features = {
	"zero", -- Use a slashed zero '0' (instead of dotted)
	"kern", -- (default) kerning (todo check what is really is)
	"liga", -- (default) ligatures
	"clig", -- (default) contextual ligatures
}

return cfg
