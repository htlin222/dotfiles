return { --twilight
	"folke/twilight.nvim",
	event = "VeryLazy",
	keys = {
		{ -- example for lazy-loading on keystroke
			"<leader>tl",
			"<cmd>Twilight<CR>",
			mode = { "n", "o", "x" },
			desc = "Toggle Twilight",
		},
	},
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
	},
}
