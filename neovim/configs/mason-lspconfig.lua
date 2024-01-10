return {
	"williamboman/mason-lspconfig.nvim",
	event = "VeryLazy",
	filetypes = { "python", "markdown", "html", "lua", "yaml", "bib", "json", "text", "sh", "dot", "gv", "json" },
	dependencies = {
		"williamboman/mason.nvim",
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
		require("mason-lspconfig").setup({
			ensure_installed = {
				"bashls",
				"html",
				"lua_ls",
				"marksman",
				"prosemd_lsp",
				"pyright",
				"remark_ls",
				"rust_analyzer",
				-- "vale_ls",
				"vimls",
				"sourcery",
				"yamlls",
				"ruff_lsp",
				"r_language_server",
				"ltex",
				"cssls",
				"pylyzer",
				"pyre",
			},
			automatic_installation = true,
		})
		-- https://github.com/neovim/nvim-lspconfig/tree/master/lua/lspconfig/server_configurations
		local root_dir = function()
			return vim.loop.cwd()
		end
		local config = require("plugins.configs.lspconfig")
		-- local util = require("lspconfig.util")
		local on_attach = config.on_attach
		local capabilities = config.capabilities
		local lspconfig = require("lspconfig")
		local servers = {
			"html",
			"cssls",
			"clangd",
			"r_language_server",
			"ruff_lsp",
			-- "yamlls",
			"quick_lint_js",
			-- "zk",
			-- "remark_ls",
			-- "vale_ls",
			"marksman",
			"rust_analyzer",
			"vimls",
			"lua_ls",
		}

		for _, lsp in ipairs(servers) do
			lspconfig[lsp].setup({
				on_attach = on_attach,
				capabilities = capabilities,
			})
		end
		lspconfig.bashls.setup({
			on_attach = on_attach,
			filetypes = { "bash", "sh", "zsh" },
		})
		lspconfig.vale_ls.setup({
			on_attach = on_attach,
			filetypes = { "text", "txt" },
		})
		lspconfig.dotls.setup({
			on_attach = on_attach,
			filetypes = { "dot", "graphviz", "gv" },
		})
	end,
}
