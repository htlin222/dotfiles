return {
  "Isrothy/neominimap.nvim",
  enabled = true,
  lazy = true, -- 啟用延遲加載以提升啟動性能
  cmd = { "Neominimap" }, -- 只在需要時加載
  keys = {
    { "<leader>nm", "<cmd>Neominimap toggle<cr>", desc = "Toggle Neominimap" },
  },
  init = function()
    vim.opt.wrap = false -- Recommended
    vim.opt.sidescrolloff = 36 -- It's recommended to set a large value
    vim.g.neominimap = {
      auto_enable = false,
    }
  end,
}
