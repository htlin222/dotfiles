local options = {
  formatters_by_ft = {
        lua = { "stylua" },
    -- css = { "prettier" },
    -- html = { "prettier" },
				javascript = { "prettier" },
				dot = { "clang_format" },
				-- typescript = { "prettier" },
				-- javascriptreact = { "prettier" },
				-- typescriptreact = { "prettier" },
				-- css = { "prettier", "stylelint" },
				-- r = { "styler", "squeeze_blanks", "trim_whitespace" }, -- remotes::install_github("devOpifex/r.nvim")
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
				python = { "black", "ruff_fix", "ruff_format", "isort", "mypy" },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

require("conform").setup(options)
