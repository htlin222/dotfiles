local vim = vim
return {
  "evanpurkhiser/image-paste.nvim",
  keys = {
    { -- example for lazy-loading on keystroke
      "<leader>pa",
      "<cmd>lua require('image-paste').paste_image()<cr>",
      mode = { "n" },
      desc = "paste_image",
    },
  },
  config = function()
    local opts = {
      imgur_client_id = "713cacc415ed391",
    }
    if vim.bo.filetype == "markdown" then
      opts.image_name = "h:450px"
    elseif vim.bo.filetype == "quarto" then
      opts.image_name = "Caption:"
    end
    require("image-paste").setup(opts)
  end,
}
