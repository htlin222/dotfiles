return {
  "dzfrias/arena.nvim",
  -- event = "BufWinEnter",
  -- Calls `.setup()` automatically
  keys = { -- Example mapping to toggle outline
    { "<leader>or", "<cmd>ArenaToggle<CR>", desc = "Toggle ArenaToggle" },
  },
  config = true,
}
