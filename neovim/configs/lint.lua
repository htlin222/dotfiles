return {
	"mfussenegger/nvim-lint",
	"mason-nvim-lint",
	lazy = true,
	event = { "BufReadPre", "BufNewFile" }, -- to disable, comment this out
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			sql = { "sqlfluff" },
			typescriptreact = { "eslint_d" },
			svelte = { "eslint_d" },
			json = { "jsonlint" },
			dot = { "cpplint" },
			gv = { "cpplint" },
			groovy = { "groovyls" },
			python = { "ruff" },
			vim = { "vint" },
			markdown = { "proselint" },
			yaml = { "yamllint" },
			yml = { "yamllint" },
			bash = { "shellcheck" },
			text = { "vale" },
		}
		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})
		vim.keymap.set("n", "<leader>l", function()
			lint.try_lint()
		end, { desc = "Trigger linting for current file" })
		require("mason-nvim-lint").setup({
			ensure_installed = {
				"eslint_d",
				"sqlfluff",
				"jsonlint",
				"cpplint",
				"vint",
				"ruff",
				"pylint",
				"pydocstyle",
				"yamllint",
				"vale",
				"groovyls",
				"shellcheck",
				"proselint",
			},
			automatic_installation = true,
		})
	end,
}
