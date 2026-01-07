-- Track buffers modified by user (not external tools like Claude Code)
local user_modified_buffers = {}

-- Mark buffer as user-modified when user makes changes
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  callback = function(args)
    user_modified_buffers[args.buf] = true
  end,
})

-- Clear flag when buffer is written or unloaded
vim.api.nvim_create_autocmd({ "BufWritePost", "BufUnload" }, {
  callback = function(args)
    user_modified_buffers[args.buf] = nil
  end,
})

-- Clear flag when file is reloaded from disk (external change)
vim.api.nvim_create_autocmd({ "FileChangedShellPost", "BufReadPost" }, {
  callback = function(args)
    user_modified_buffers[args.buf] = nil
  end,
})

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

  -- Smart format_on_save: only format if user modified the buffer
  -- This prevents formatting when external tools (Claude Code, git, etc.) modify files
  format_on_save = function(bufnr)
    -- Skip if buffer wasn't modified by user
    if not user_modified_buffers[bufnr] then
      return nil -- Skip formatting
    end

    return {
      timeout_ms = 2000,
      lsp_fallback = false,
    }
  end,
}

require("conform").setup(options)
