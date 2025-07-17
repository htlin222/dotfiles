return {
  "jmbuhr/telescope-zotero.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
    "kkharji/sqlite.lua",
  },
  config = function()
    require("telescope").load_extension("zotero")
  end,
}