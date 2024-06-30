return {
  "yamatsum/nvim-cursorline",
  event = "VeryLazy",
  config = function()
    require("nvim-cursorline").setup {
      cursorline = {
        enable = true,
        timeout = 0,
        number = true,
      },
      cursorword = {
        enable = true,
        min_length = 3,
        hl = { underline = true },
      },
    }
  end,
}
