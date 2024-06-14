return {
	"chrisgrieser/nvim-spider",
	keys = {
		{ -- example for lazy-loading on keystroke
			"e",
			"<cmd>lua require('spider').motion('e')<CR>",
			mode = { "n", "o", "x" },
		},
		{ -- example for lazy-loading on keystroke
			"b",
			"<cmd>lua require('spider').motion('b')<CR>",
			mode = { "n", "o", "x" },
		},
		{ -- example for lazy-loading on keystroke
			"w",
			"<cmd>lua require('spider').motion('w')<CR>",
			mode = { "n", "o", "x" },
		},
	},
}
-- https://github.com/chrisgrieser/nvim-spider
