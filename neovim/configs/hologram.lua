return {
  "edluffy/hologram.nvim",
  event = "VeryLazy",
  config = function()
    require("hologram").setup({
      auto_display = true, -- WIP automatic markdown image display, may be prone to breaking
    })
  end,
}
