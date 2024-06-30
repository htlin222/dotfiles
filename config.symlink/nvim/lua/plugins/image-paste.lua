return {
  "evanpurkhiser/image-paste.nvim",
  keys = {
    { -- example for lazy-loading on keystroke
      "<leader>pp",
      "<cmd>lua require('image-paste').paste_image()<cr>",
      mode = { "n" },
      desc = "paste_image",
    },
  },

  config = function()
    require("image-paste").setup {
      imgur_client_id = "713cacc415ed391",
      image_name = "height:450px",
    }
  end,
}
