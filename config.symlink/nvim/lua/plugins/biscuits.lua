-- DISABLED: nvim-biscuits uses deprecated nvim-treesitter.ts_utils API
-- Re-enable when plugin is updated for new nvim-treesitter
return {
  "code-biscuits/nvim-biscuits",
  enabled = false,
  event = "VeryLazy",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
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
