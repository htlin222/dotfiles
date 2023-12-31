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
			fat_headlines = true,
			fat_headline_upper_string = "▃",
			fat_headline_lower_string = "󰗈",
			dash_string = "-",
		},
	},
}
