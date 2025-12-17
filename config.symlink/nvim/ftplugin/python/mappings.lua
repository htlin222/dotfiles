local nio = require "nio"
local vim = vim
local function map(modes, lhs, rhs, opts)
  -- opts.unique = opts.unique ~= false
  opts.silent = opts.silent ~= false
  opts.nowait = opts.nowait ~= false
  vim.keymap.set(modes, lhs, rhs, opts)
end
-- Normal mode --
-- map("n", "<CR>", ":", { desc = "iron sent line", silent = false })
