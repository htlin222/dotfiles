local vim = vim
return {
  "htlin222/image-paste.nvim",
  -- private repo: a Codespace's scoped GITHUB_TOKEN gets 403 cloning it,
  -- which makes lazy error on every startup. Skip it there only.
  enabled = vim.env.CODESPACES == nil,
  keys = {
    { -- example for lazy-loading on keystroke
      "<leader>pa",
      "<cmd>lua require('image-paste').paste_image()<cr>",
      mode = { "n" },
      desc = "paste_image",
    },
  },
  config = function()
    local opts = {}
    if vim.bo.filetype == "markdown" then
      opts.image_name = "h:450px"
    elseif vim.bo.filetype == "quarto" then
      opts.image_name = "Caption:"
    end
    require("image-paste").setup(opts)
  end,
}
