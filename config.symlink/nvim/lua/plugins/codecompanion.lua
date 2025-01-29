return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  event = "VeryLazy",
  opts = {
    strategies = {
      -- Change the default chat adapter
      chat = {
        adapter = "anthropic",
      },
    },
  },
}
