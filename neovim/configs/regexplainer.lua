return {
  "bennypowers/nvim-regexplainer",
  -- event = "VeryLazy",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("regexplainer").setup()
  end,
}
