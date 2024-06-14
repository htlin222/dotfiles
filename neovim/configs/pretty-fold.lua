return { --pretty-fold
	"anuvyklack/pretty-fold.nvim",
	-- lazy = false,
	event = "VeryLazy",
	config = function()
		require("pretty-fold").setup()
	end,
}
