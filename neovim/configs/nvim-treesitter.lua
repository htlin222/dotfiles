return { --nvim-treesitter
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	opts = {
		highlight = { enable = true },
		indent = { enable = true },
		incremental_selection = {
			enable = false,
			keymaps = {
				init_selection = "<C-space>",
				node_incremental = "<C-space>",
				scope_incremental = false,
				node_decremental = "<C-bs>",
			},
		},
		-- highlight = {
		-- 	enable = true,
		-- 	-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
		-- 	-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
		-- 	-- Using this option may slow down your editor, and you may see some duplicate highlights.
		-- 	-- Instead of true it can also be a list of languages
		-- 	additional_vim_regex_highlighting = false,
		-- },
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
