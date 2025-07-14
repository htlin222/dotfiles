return {
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" }, -- to disable, comment this out
    config = function()
      require "configs.conform"
    end,
  },
  { "echasnovski/mini.nvim", version = false },
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
      -- 優化：移除重複和未使用的工具，按需安裝以提升啟動速度
      ensure_installed = {
        -- LSP servers (核心)
        "bash-language-server",
        "lua-language-server", 
        "json-lsp",
        "typescript-language-server",
        
        -- Python 工具 (合併重複)
        "ruff", -- 替代 ruff-lsp, pyright, pylyzer, isort, docformatter
        
        -- 格式化工具
        "stylua",
        "prettier", 
        "beautysh",
        "shfmt",
        
        -- Linting (核心)
        "selene",
        "shellcheck",
        "jsonlint",
        "quick-lint-js",
        
        -- 特定語言支持
        "julia-lsp",
        "groovy-language-server",
        
        -- 實用工具
        "bibtex-tidy",
        "fixjson",
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
