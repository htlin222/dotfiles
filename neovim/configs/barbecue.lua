return {
  "utilyre/barbecue.nvim",
  -- lazy = false,
  event = "VeryLazy",
  name = "barbecue",
  version = "*",
  dependencies = {
    "SmiteshP/nvim-navic",
    "nvim-tree/nvim-web-devicons", -- optional dependency
  },
  opts = {
    -- configurations go here
  },
  config = function()
    require("barbecue").setup()
  end,
}
