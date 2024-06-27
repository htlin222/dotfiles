-- [Wansmer/treesj: Neovim plugin for splitting/joining blocks of code](https://github.com/Wansmer/treesj)
return {
  "Wansmer/treesj",
  dependencies = { "nvim-treesitter/nvim-treesitter" }, -- if you install parsers with `nvim-treesitter`
  config = function()
    require("treesj").setup {--[[ your config ]]
      use_default_keymaps = false,
    }
  end,
}
