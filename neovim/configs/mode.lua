return {
  "mvllow/modes.nvim",
  -- lazy = false,
  event = "VeryLazy",
  tag = "v0.2.0",
  config = function()
    require("modes").setup()
    vim.api.nvim_set_hl(0, "Cursor", { fg = "#cc9900", bg = "#339966" })
  end,
}
