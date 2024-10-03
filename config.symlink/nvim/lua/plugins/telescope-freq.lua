return {
  "nvim-telescope/telescope-frecency.nvim",
  event = "VeryLazy",
  keys = { -- Example mapping to toggle outline
    { "<leader>fq", "<cmd>Telescope frecency<CR>", desc = "Telescope frecency" },
  },
  config = function()
    require("telescope").load_extension "frecency"
  end,
}
