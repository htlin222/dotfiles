return { --nvim-treesitter
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	opts = {
		incremental_selection = {
			enable = false,
			keymaps = {
				init_selection = "<C-space>",
				node_incremental = "<C-space>",
				scope_incremental = false,
				node_decremental = "<C-bs>",
			},
		},
		ensure_installed = {
			"bash",
			"bibtex",
			"html",
			"javascript",
			"json",
			"lua",
			"make",
			"markdown",
			"markdown_inline",
			"python",
			"query",
			"regex",
			"toml",
			"tsx",
			"typescript",
			"vim",
			"yaml",
		},
	},
}
