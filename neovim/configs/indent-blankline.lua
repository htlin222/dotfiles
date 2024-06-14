return {
  -- indent-blankline
  "lukas-reineke/indent-blankline.nvim", --
  event = "VeryLazy",
  -- ft = {"markdown"},
  -- cmd = {'indent-blankline'},
  -- lazy = true,
  -- event = { "BufReadPre " .. vim.fn.expand "~" .. "/path/to/your/file/**.md" },
  -- dependencies = {'nvim-telescope/telescope.nvim'},
  config = function()
    vim.opt.termguicolors = true
    vim.cmd([[highlight IndentBlanklineIndent1 guibg=#1f1f1f gui=nocombine]])
    vim.cmd([[highlight IndentBlanklineIndent2 guibg=#1a1a1a gui=nocombine]])

    require("indent_blankline").setup({
      char = "",
      char_highlight_list = {
        "IndentBlanklineIndent1",
        "IndentBlanklineIndent2",
      },
      space_char_highlight_list = {
        "IndentBlanklineIndent1",
        "IndentBlanklineIndent2",
      },
      show_trailing_blankline_indent = false,
    })
  end,
}

-- 2023-07-05 23:23:03 modified by Hsieh-Ting Lin 🦎
-- info: 1izard@duck.com
-- vim.fn.expand("%:p")
-- print(vim.fn.expand("%:p:h"))
