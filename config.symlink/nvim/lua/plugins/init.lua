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
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server",
        "stylua",
        "selene",
        "markdownlint-cli2",
        "html-lsp",
        "css-lsp",
        "prettier",
        "bashls",
        "ruff",
        "markdown-oxide",
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
      },
    },
  },
}
