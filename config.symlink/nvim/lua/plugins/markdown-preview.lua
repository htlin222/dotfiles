return {
  "iamcco/markdown-preview.nvim",
  lazy = true, -- 修正：已有cmd和keys觸發器，應該啟用lazy加載
  ft = { "markdown", "quarto" }, -- 只在markdown文件時加載
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
