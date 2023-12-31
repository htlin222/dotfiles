return { --quicknote
  "RutaTang/quicknote.nvim",
  -- event = "VeryLazy",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("quicknote").setup({})
  end,
}
