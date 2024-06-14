return {
  "matbme/JABS.nvim",
  -- lazy = false,
  event = "VeryLazy",
  config = function()
    require("jabs").setup({})
  end,
}
