local vim = vim
return {
  "gbprod/substitute.nvim",
  -- event = "VeryLazy",
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
  config = function()
    require("substitute").setup {}
    -- vim.keymap.set("n", "s", require("substitute").operator, { noremap = true })
    -- vim.keymap.set("n", "ss", require("substitute").line, { noremap = true })
    -- vim.keymap.set("n", "S", require("substitute").eol, { noremap = true })
    -- vim.keymap.set("x", "s", require("substitute").visual, { noremap = true })
  end,
}
-- [gbprod/substitute.nvim: Neovim plugin introducing a new operators motions to quickly replace and exchange text.](https://github.com/gbprod/substitute.nvim)
