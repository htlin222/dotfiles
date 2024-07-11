return {
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" }, -- to disable, comment this out
    config = function()
      require "configs.conform"
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },
  -- {
  --   "rachartier/tiny-inline-diagnostic.nvim",
  --   event = "VeryLazy",
  --   config = function()
  --     require("tiny-inline-diagnostic").setup()
  --   end,
  -- },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "julia-lsp",
        "alex",
        "ast-grep",
        "bash-language-server",
        "beautysh",
        "bibtex-tidy",
        "black",
        "cbfmt",
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
        "julia",
        "python",
        "r",
        "tmux",
        "toml",
        "vim",
        "vimdoc",
        "yaml",
      },
    },
  },
}
