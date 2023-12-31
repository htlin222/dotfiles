return { --null-ls
  "jose-elias-alvarez/null-ls.nvim",
  -- lazy = true,
  event = "VeryLazy",
  opts = function()
    return require("custom.configs.null-ls")
    -- load config in the null-ls.lua
    -- TODO: maybe there is a better way to do this
  end,
}
