vim.cmd([[highlight Headline1 guibg=#1e2718]])
vim.cmd([[highlight Headline2 guibg=#21262d]])
return {
	-- init.lua
	"lukas-reineke/headlines.nvim",
	dependencies = "nvim-treesitter/nvim-treesitter",
	-- lazy = false,
	ft = { "markdown", "md" },
	event = "VeryLazy",
	config = true,
	opts = {
		markdown = {
			headline_highlights = { "Headline1", "Headline2" },
			-- fat_headlines = true,
			-- fat_headline_upper_string = "▃",
			-- fat_headline_lower_string = "󰗈",
			-- dash_string = "-",
		},
	},
}
