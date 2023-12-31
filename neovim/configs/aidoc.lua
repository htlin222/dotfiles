return {
  "moozd/aidoc.nvim",
  event = "VeryLazy",
  ft = { "python" },
  config = function()
    require("aidoc").setup({
      email = "<your email is optional>",
      width = 65,
      keymap = "<leader>do",
    })
  end,
}
