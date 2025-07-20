return {
  -- Air: R language server with formatting capabilities
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "air" })
      return opts
    end,
  },
  
  -- Ensure Air is available as a formatter for conform.nvim
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters = {
        air = {
          command = vim.fn.expand('~/.local/share/nvim/mason/bin/air'),
          args = { "format", "--stdin" },
          stdin = true,
        },
      },
    },
  },
}