return {
  "Isrothy/neominimap.nvim",
  enabled = true,
  lazy = false, -- WARN: NO NEED to Lazy load
  init = function()
    vim.opt.wrap = false -- Recommended
    vim.opt.sidescrolloff = 36 -- It's recommended to set a large value
    vim.g.neominimap = {
      auto_enable = false,
    }
  end,
}
