local col = {}

-- Colors converted from Catppuccin Latte theme
col.background = "#eff1f5"
col.foreground = "#4c4f69"

col.cursor_bg = "#dc8a78"
col.cursor_fg = "#dce0e8"
col.cursor_border = "#dc8a78" -- same as cursor_bg

col.ansi = {
	"#bcc0cc", -- black
	"#d20f39", -- red
	"#40a02b", -- green
	"#df8e1d", -- yellow
	"#1e66f5", -- blue
	"#ea76cb", -- magenta
	"#179299", -- cyan
	"#5c5f77", -- white
}

col.brights = {
	"#acb0be", -- bright black
	"#d20f39", -- bright red
	"#40a02b", -- bright green
	"#df8e1d", -- bright yellow
	"#1e66f5", -- bright blue
	"#ea76cb", -- bright magenta
	"#179299", -- bright cyan
	"#6c6f85", -- bright white
}

col.indexed = {
	[16] = "#fe640b",
	[17] = "#dc8a78",
}

-- Slightly grayish selection with clear fg
col.selection_bg = "#acb0be"
col.selection_fg = "#4c4f69"

-- Additional optional properties (not always used in all terminals)
col.scrollbar_thumb = "#acb0be"
col.split = "#9ca0b0"
col.visual_bell = "#ccd0da"

-- Tab bar
col.tab_bar = {
	background = "#dce0e8",
	inactive_tab_edge = "#ccd0da",

	active_tab = {
		bg_color = "#8839ef",
		fg_color = "#dce0e8",
	},

	inactive_tab = {
		bg_color = "#e6e9ef",
		fg_color = "#4c4f69",
	},

	inactive_tab_hover = {
		bg_color = "#eff1f5",
		fg_color = "#4c4f69",
	},

	new_tab = {
		bg_color = "#ccd0da",
		fg_color = "#4c4f69",
	},

	new_tab_hover = {
		bg_color = "#bcc0cc",
		fg_color = "#4c4f69",
	},
}

return col
