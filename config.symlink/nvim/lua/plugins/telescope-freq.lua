return {
  "nvim-telescope/telescope-frecency.nvim",
  event = "VeryLazy",
  config = function()
    require("telescope").load_extension "frecency"
  end,
}
