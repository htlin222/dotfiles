return { --lspconfig
	"neovim/nvim-lspconfig",
	filetypes = { "python", "markdown", "html", "lua", "yaml", "bib" },
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		{
			"SmiteshP/nvim-navbuddy",
			dependencies = {
				"SmiteshP/nvim-navic",
				"MunifTanjim/nui.nvim",
			},
			opts = { lsp = { auto_attach = true } },
		},
	},
	config = function()
		require("plugins.configs.lspconfig")
	end,
}
