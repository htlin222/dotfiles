return {
  "hedyhli/outline.nvim",
  lazy = true,
  cmd = { "Outline", "OutlineOpen" },
  keys = { -- Example mapping to toggle outline
    { "<leader>ou", "<cmd>Outline<CR>", desc = "Toggle outline" },
  },
  opts = {
    -- Your setup opts here
    providers = {
      markdown = {
        filetypes = { "markdown", "rmarkdown", "quarto" },
      },
      python = {
        filetypes = { "python" },
      },
    },
  },
}
