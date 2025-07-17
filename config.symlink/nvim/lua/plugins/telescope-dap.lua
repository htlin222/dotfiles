return {
  "nvim-telescope/telescope-dap.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "mfussenegger/nvim-dap",
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("telescope").load_extension("dap")
  end,
}