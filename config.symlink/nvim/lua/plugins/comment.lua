return { --comment
  "numToStr/Comment.nvim",
  event = "VeryLazy", --
  -- lazy = false,
  config = function()
    require("Comment").setup()
  end,
}
