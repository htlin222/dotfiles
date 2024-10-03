return {
  -- A code outline window for skimming and quick navigation
  "stevearc/aerial.nvim",
  event = "VeryLazy",
  opts = {},
  -- Optional dependencies
  keys = { -- Example mapping to toggle outline
    { "<leader>oa", "<cmd>AerialToggle<CR>", desc = "Toggle AerialToggle" },
  },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
}
