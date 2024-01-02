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
				r = { "styler" },
				scss = { "prettier", "stylelint" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "yamlfmt" },
				yml = { "prettier", "yamlfmt" },
				sql = { "sql_formatter" },
				sh = { "beautysh", "shfmt", "shellcheck" },
				zsh = { "beautysh", "shellcheck" },
				markdown = { "prettier", "markdownlint", "autocorrect" },
				graphql = { "prettier" },
				lua = { "stylua" },
				python = { "black", "reorder_python_imports", "autoflake", "autopep8" },
			},
			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 2000,
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
