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

local iron = require "iron.core"

iron.setup {
  config = {
    keymaps = {
      send_line = "<CR>",
    },
    -- If the highlight is on, you can change how it looks
    -- For the available options, check nvim_set_hl
    highlight = {
      italic = true,
    },
    ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
  },
}
