return {
  "limxingzhi/toychest.nvim",
  config = function()
    require("toychest").setup {
      dir = "~/.my_sessions", -- directory for your sessions
    }
  end,
}
