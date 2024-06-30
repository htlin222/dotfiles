return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  -- lazy = false,
  keys = {
    { -- example for lazy-loading on keystroke
      "<C-N>",
      "<cmd>NvimTreeToggle<CR>",
      mode = { "n" },
      desc = "NvimTreeToggle",
    },
  },
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup {
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      update_focused_file = {
        enable = true,
        update_root = true,
      },
    }
  end,
}
