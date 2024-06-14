return {
  "MeanderingProgrammer/markdown.nvim",
  name = "render-markdown",   -- Only needed if you have another plugin named markdown.nvim
  ft = { "markdown", "quarto", "qmd" },
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("render-markdown").setup({
      file_types = { "markdown", "quarto" },
    })
  end,
}
