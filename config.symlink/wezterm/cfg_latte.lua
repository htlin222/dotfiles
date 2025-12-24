local col = {}

-- High contrast light theme
col.background = "#fafafa"
col.foreground = "#1a1a1a"

col.cursor_bg = "#d02020"
col.cursor_fg = "#fafafa"
col.cursor_border = "#d02020"

-- High contrast ANSI colors for light background
col.ansi = {
	"#1a1a1a", -- black (true black for max contrast)
	"#c41a16", -- red (dark red)
	"#007400", -- green (dark green)
	"#aa5500", -- yellow (dark orange/brown for readability)
	"#0451a5", -- blue (dark blue)
	"#a626a4", -- magenta (purple)
	"#0184bc", -- cyan (dark cyan)
	"#d0d0d0", -- white
}

col.brights = {
	"#505050", -- bright black (dark gray)
	"#e45649", -- bright red
	"#50a14f", -- bright green
	"#c18401", -- bright yellow
	"#4078f2", -- bright blue
	"#ca1243", -- bright magenta
	"#20a5ba", -- bright cyan
	"#fafafa", -- bright white
}

col.indexed = {
	[16] = "#d75f00",
	[17] = "#af0000",
}

-- Clear selection highlighting
col.selection_bg = "#add6ff"
col.selection_fg = "#1a1a1a"

col.scrollbar_thumb = "#c0c0c0"
col.split = "#808080"
col.visual_bell = "#e0e0e0"

-- Tab bar
col.tab_bar = {
	background = "#e8e8e8",
	inactive_tab_edge = "#d0d0d0",

	active_tab = {
		bg_color = "#fafafa",
		fg_color = "#1a1a1a",
	},

	inactive_tab = {
		bg_color = "#d0d0d0",
		fg_color = "#505050",
	},

	inactive_tab_hover = {
		bg_color = "#e0e0e0",
		fg_color = "#1a1a1a",
	},

	new_tab = {
		bg_color = "#c0c0c0",
		fg_color = "#505050",
	},

	new_tab_hover = {
		bg_color = "#d0d0d0",
		fg_color = "#1a1a1a",
	},
}

return col
