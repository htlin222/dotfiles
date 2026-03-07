return {
  "Cannon07/claude-preview.nvim",
  event = "VeryLazy",
  config = function()
    require("claude-preview").setup()
  end,
}
