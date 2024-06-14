return { --quicknote
  "petertriho/nvim-scrollbar",
  event = "VeryLazy",
  -- lazy = false,
  config = function()
    require("scrollbar").setup()
  end,
}
