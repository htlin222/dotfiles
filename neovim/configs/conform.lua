return {
	"stevearc/conform.nvim",
	lazy = true,
	event = { "BufReadPre", "BufNewFile" }, -- to disable, comment this out
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				javascript = { "prettier" },
				dot = { "clang_format" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				svelte = { "prettier" },
				css = { "prettier", "stylelint" },
				r = { "styler", "squeeze_blanks", "trim_whitespace" }, -- remotes::install_github("devOpifex/r.nvim")
				scss = { "prettier", "stylelint" },
				html = { "prettier" },
				json = { "fixjson" },
				yaml = { "yamlfmt" },
				toml = { "taplo" },
				bib = { "bibtex-tidy" },
				yml = { "prettier", "yamlfmt" },
				sql = { "sql_formatter" },
				sh = { "beautysh", "shfmt", "shellcheck" },
				zsh = { "beautysh", "shellcheck" },
				markdown = { "prettier", "markdownlint-cli2", "codespell" },
				quarto = { "prettier", "markdownlint-cli2", "codespell" },
				qmd = { "prettier", "markdownlint-cli2", "codespell" },
				graphql = { "prettier" },
				groovy = { "npm_groovy_lint" },
				lua = { "stylua" },
				python = { "black", "ruff_fix", "ruff_format", "isort", "mypy" },
			},
			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 2000,
			},
			formatters = {
				clang_format = {
					cwd = require("conform.util").root_file({ ".clang-format", "_clang-format" }),
					require_cwd = true,
				},
				prettier = {
					cwd = require("conform.util").root_file({ ".prettierrc.json" }),
					require_cwd = false,
				},
				styler = {
					cwd = require("conform.util").root_file({ ".rnvim" }),
					require_cwd = false,
				},
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 2000,
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
