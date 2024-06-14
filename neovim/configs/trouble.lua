return { --trouble
	"folke/trouble.nvim",
	-- lazy = false,
	event = "VeryLazy",
	keys = {
		{ -- example for lazy-loading on keystroke
			"<leader>tr",
			"<cmd>TroubleToggle document_diagnostics<CR>",
			mode = { "n", "o", "x" },
			desc = "Trouble Toggle document_diagnostics",
		},
	},
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		-- https://github.com/folke/trouble.nvim
		-- refer to the configuration section below
	},
}
