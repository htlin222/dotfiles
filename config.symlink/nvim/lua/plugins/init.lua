return {
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" }, -- to disable, comment this out
    config = function()
      require "configs.conform"
    end,
  },
  { "echasnovski/mini.nvim", version = false, event = "VeryLazy" },
  { "nvim-java/nvim-java", ft = "java" },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- Load NvChad LSP base setup (diagnostics, base46 theme, LspAttach keymaps)
      local uv = vim.uv or vim.loop
      local lsp_cache = vim.g.base46_cache .. "lsp"
      if uv.fs_stat(lsp_cache) then
        pcall(dofile, lsp_cache)
      end
      require("nvchad.lsp").diagnostic_config()
      -- Load custom LSP configurations using vim.lsp.config API
      require "configs.lspconfig"
    end,
  },
  {
    "williamboman/mason.nvim",
    event = "VeryLazy",
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
    event = { "BufReadPost", "BufNewFile" },
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
