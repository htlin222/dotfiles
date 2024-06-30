return { --zen-mode
  "folke/zen-mode.nvim",
  -- event = "VeryLazy",
  keys = {
    { -- example for lazy-loading on keystroke
      "<leader>zm",
      "<cmd>ZenMode<CR>",
      mode = { "n", "o", "x" },
      desc = "ZenMode",
    },
  },
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
}
