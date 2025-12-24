local options = {
  formatters_by_ft = {
    lua = {
      "stylua",
      -- "ast-grep",
    },
    -- css = { "prettier" },
    -- html = { "prettier" },
    javascript = { "biome" },
    javascriptreact = { "biome" },
    dot = { "clang_format" },
    typescript = { "biome" },
    -- javascriptreact = { "prettier" },
    typescriptreact = { "biome" },
    css = { "prettier", "stylelint" },
    r = { "air" }, -- Use Air for R formatting
    rmd = { "injected" }, -- Use injected language formatting for RMarkdown
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
    markdown = { "markdownlint-cli2" },
    quarto = { "injected" }, -- Use injected language formatting for Quarto
    graphql = { "prettier" },
    groovy = { "google-java-format" },
    python = { "ruff_fix", "ruff_format", "isort", "mypy", "docformatter" },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 2000, -- 減少超時時間以避免阻塞
    lsp_fallback = false,
  },
}

require("conform").setup(options)
