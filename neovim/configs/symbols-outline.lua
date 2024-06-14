return { --symbols-outline
  "simrat39/symbols-outline.nvim",
  event = "VeryLazy",
  config = function()
    require("symbols-outline").setup({
      auto_close = true,
      wrap = true,
      show_relative_numbers = true,
      autofold_depth = 4,
      width = 25,
    })
  end,
}
