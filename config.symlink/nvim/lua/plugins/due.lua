local vim = vim
return {
  "NFrid/due.nvim",
  -- lazy = true,
  event = "VeryLazy",
  config = function()
    require("due_nvim").setup {
      prescript = "Due: ", -- prescript to due data
      prescript_hi = "Comment", -- highlight group of it
      due_hi = "String", -- highlight group of the data itself
      ft = "*.md", -- filename template to apply aucmds :)
      today = "TODAY", -- text for today's due
      today_hi = "Character", -- highlight group of today's due
      overdue = "OVERDUE", -- text for overdued
      overdue_hi = "Error", -- highlight group of overdued
      date_hi = "Conceal", -- highlight group of date string

      pattern_start = "- ", -- start for a date string pattern
      pattern_end = "", -- end for a date string pattern
      -- lua patterns: in brackets are 'groups of data', their order is described
      -- accordingly. More about lua patterns: https://www.lua.org/pil/20.2.html
      date_pattern = "(%d%d)%-(%d%d)", -- m, d

      regex_hi = "\\d*-*\\d\\+-\\d\\+\\( \\d*:\\d*\\( \\a\\a\\)\\?\\)\\?",
      -- vim regex for highlighting, notice double
      -- backslashes cuz lua strings escaping
      use_clock_time = true, -- display also hours and minutes
      use_clock_today = false, -- do it instead of TODAY
      use_seconds = false, -- if use_clock_time == true, display seconds
      -- as well
      default_due_time = "midnight", -- if use_clock_time == true, calculate time
      -- until option on specified date. Accepts
      -- "midnight", for 23:59:59, or noon, for
      -- 12:00:00
    }
    local map = vim.keymap.set
    -- normal mode --
    map("n", "<leader>du", function()
      require("due_nvim").draw(0)
      print "Draw Due ⏳"
    end, { desc = "Draw Due", nowait = true, silent = false })
    --
  end,
}
