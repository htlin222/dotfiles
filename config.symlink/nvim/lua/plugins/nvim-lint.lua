local vim = vim
return {
  "mfussenegger/nvim-lint",
  event = "VeryLazy",
  -- event = { "BufReadPre", "BufNewFile" },
  config = function()
    require "configs.lint"
  end,
}
