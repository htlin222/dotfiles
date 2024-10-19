return {
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" }, -- to disable, comment this out
    config = function()
      require "configs.conform"
    end,
  },
  { "nvim-java/nvim-java" },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
      ensure_installed = {
        "julia-lsp",
        "ast-grep",
        "bash-language-server",
        "beautysh",
        "bibtex-tidy",
        -- "jupytext",
        "cbfmt",
        "clang_format",
        "docformatter",
        "jupytext",
        "checkstyle",
        "clang-format",
        "codespell",
        "dot-language-server",
        "fixjson",
        "google-java-format",
        "groovy-language-server",
        "harper-ls",
        "isort",
        "json-lsp",
        "jsonlint",
        "lua-language-server",
        "markdown-oxide",
        "markdown-toc",
        "markdownlint-cli2",
        "misspell",
        "mypy",
        "npm-groovy-lint",
        "prettier",
        "pylyzer",
        "pyright",
        "ruff",
        "ruff-lsp",
        "selene",
        "shellcheck",
        "shfmt",
        "stylua",
        "taplo",
        "typos",
        "vale",
        "vale-ls",
        "write-good",
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "css",
        "bash",
        "dot",
        "html",
        "json",
        "lua",
        "markdown",
        "javascript",
        "markdown_inline",
        "r",
        "rnoweb",
        "julia",
        "python",
        "tmux",
        "toml",
        "vim",
        "vimdoc",
        "yaml",
      },
    },
  },
}
