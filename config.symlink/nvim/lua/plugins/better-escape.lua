return {
	"max397574/better-escape.nvim",
	enabled = false,  -- disabled
	event = "VeryLazy",
	config = function()
		require("better_escape").setup({
			mapping = {"jk", "kj"},
			timeout = 200,  -- increase timeout to be less aggressive
			clear_empty_lines = false,
			keys = "<Esc>",
		})
	end,
}
