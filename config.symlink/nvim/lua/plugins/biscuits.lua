return {
  "code-biscuits/nvim-biscuits",
  event = "VeryLazy",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
  },
  keys = {
    {
      "<leader>ab",
      function()
        local nvim_biscuits = require "nvim-biscuits"
        nvim_biscuits.BufferAttach()
        nvim_biscuits.toggle_biscuits()
      end,
      mode = "n",
      desc = "Enable Biscuits",
    },
  },
}
