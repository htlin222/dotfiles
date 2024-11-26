local options = {
  formatters_by_ft = {
    lua = {
      "stylua" ,
      -- "ast-grep",
    },
    -- css = { "prettier" },
    -- html = { "prettier" },
    javascript = { "biome" },
    javascriptreact = { "biome", "biome" },
    dot = { "clang_format" },
    typescript = { "biome" },
    -- javascriptreact = { "prettier" },
    typescriptreact = { "biome" },
    css = { "prettier", "stylelint" },
    -- r = { "styler", "squeeze_blanks", "trim_whitespace" }, -- remotes::install_github("devOpifex/r.nvim")
    scss = { "prettier", "stylelint" },
    html = { "prettier" },
    json = { "biome" },
    yaml = { "yamlfmt" },
    toml = { "taplo" },
    bib = { "bibtex-tidy" },
    yml = { "prettier", "yamlfmt" },
    sql = { "sql_formatter" },
    sh = { "shfmt" },
    zsh = { "shfmt" },
    markdown = { "prettier", "markdownlint-cli2" },
    quarto = { "prettier", "markdownlint-cli2", "jupytext" },
    graphql = { "prettier" },
    groovy = { "google-java-format" },
    python = { "ruff_fix", "ruff_format", "isort", "mypy", "docformatter" },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 3500,
    lsp_fallback = false,
  },
}

require("conform").setup(options)
