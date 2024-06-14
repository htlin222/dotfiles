return {
  "mawkler/modicator.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.cursorline = true
    vim.o.number = true
    vim.o.termguicolors = true
  end,
  config = function()
    require("modicator").setup()
  end,
}
