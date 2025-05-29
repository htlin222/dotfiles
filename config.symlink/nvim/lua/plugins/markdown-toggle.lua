return {
  "roodolv/markdown-toggle.nvim",
  event = "VeryLazy",
  config = function()
    require("markdown-toggle").setup {
      use_default_keymaps = false,
    }
  end,
}
