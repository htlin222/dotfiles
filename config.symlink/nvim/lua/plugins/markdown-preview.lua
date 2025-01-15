return {
  "iamcco/markdown-preview.nvim",
  lazy = false,
  cmd = { "MarkdownPreview", "MarkdownPreviewStop" },
  keys = {
    { -- example for lazy-loading on keystroke
      "<leader>mp",
      "<cmd>MarkdownPreview<CR>",
      mode = { "n", "o", "x" },
      desc = "Start Markdown Preview",
    },
  },
  build = "npm install",
  init = function()
    vim.g.mkdp_theme = "dark"
    vim.g.mkdp_filetypes = { "markdown", "quarto" }
    -- vim.g.mkdp_theme = "light"
  end,
}
