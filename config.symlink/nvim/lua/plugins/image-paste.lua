return {
  "evanpurkhiser/image-paste.nvim",
  ft = { "markdown", "quarto" },
  config = function()
    require("image-paste").setup {
      imgur_client_id = "713cacc415ed391",
      image_name = "height:450px",
    }
    vim.keymap.set(
      "n",
      "<leader>pp",
      "<cmd>lua require('image-paste').paste_image()<cr>",
      { desc = "paste_image", nowait = true, silent = true }
    )
  end,
}
