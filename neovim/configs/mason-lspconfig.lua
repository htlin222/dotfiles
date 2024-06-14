return {
	"williamboman/mason-lspconfig.nvim",
	event = "VeryLazy",
	filetypes = {
		"python",
		"markdown",
		"html",
		"lua",
		"yaml",
		"bib",
		"json",
		"text",
		"sh",
		"dot",
		"gv",
		"json",
		"r",
		"quarto",
		"groovy",
	},
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
				-- "prosemd_lsp",
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
				"groovyls",
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
		-- An example nvim-lspconfig capabilities setting
		local markdown_oxide_capabilities =
			require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
		markdown_oxide_capabilities.workspace = {
			didChangeWatchedFiles = {
				dynamicRegistration = true,
			},
		}
		local servers = {
			"html",
			"cssls",
			"clangd",
			"r_language_server",
			"ruff_lsp",
			-- "typos",
			-- "prosemd_lsp",
			-- "pylsp",
			"pyright",
			-- "yamlls",
			-- "quick_lint_js",
			"zk",
			-- "remark_ls",
			-- "vale_ls",
			-- "marksman",
			"groovyls",
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
		lspconfig.groovyls.setup({
			on_attach = on_attach,
			lsp_fallback = true,
			filetypes = { "groovy" },
		})
		lspconfig.dotls.setup({
			on_attach = on_attach,
			lsp_fallback = true,
			filetypes = { "dot", "graphviz", "gv" },
		})
		lspconfig.markdown_oxide.setup({
			capabilities = markdown_oxide_capabilities,
			on_attach = on_attach, -- configure your on attach config
		})
		lspconfig.pyright.setup({
			on_attach = on_attach,
			filetypes = { "py", "python" },
			settings = {
				pyright = {
					disableOrganizeImports = true, -- Using Ruff
				},
				python = {
					analysis = {
						ignore = { "*" }, -- Using Ruff
						typeCheckingMode = "off", -- Using mypy
					},
				},
			},
		})
	end,
}
