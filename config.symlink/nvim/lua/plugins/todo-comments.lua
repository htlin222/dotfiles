-- :TodoTelescope keywords=TODO,FIX
-- :TodoTrouble cwd=~/projects/foobar
return {
  "folke/todo-comments.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    -- NOTE: https://github.com/folke/todo-comments.nvim
    highlight = {
      comments_only = false, -- uses treesitter to match keywords in comments only
    }, -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    colors = {
      error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
      warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
      info = { "DiagnosticInfo", "#2563EB" },
      hint = { "DiagnosticHint", "#10B981" },
      default = { "Identifier", "#7C3AED" },
      test = { "Identifier", "#FF00FF" },
      tx = { "tx", "#32a862" },
      epi = { "tx", "#cf9f5d" },
    },
    search = {
      command = "rg",
      args = {
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
      },
      -- regex that will be used to match keywords.
      -- don't replace the (KEYWORDS) placeholder
      pattern = [[\b(KEYWORDS)]], -- ripgrep regex
      -- pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon. You'll likely get false positives
    },
    keywords = {
      FIX = {
        icon = " ", -- icon used for the sign, and in search results
        color = "error", -- can be a hex color, or a named color (see below)
        alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
        -- signs = false, -- configure signs for some keywords individually
      },
      TODO = {
        icon = " ",
        color = "info",
        alt = { "DONE" },
      },
      -- HACK = { icon = " ", color = "warning", alt = { "show", "Management", "TLDR", "tldr", "tl;dr" } },
      WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX", "THEN", "then", "warn" } },
      PERF = { icon = "󰓅 ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
      NOTE = {
        icon = " ",
        color = "#10B981",
        alt = {
          "fig",
          "figure",
        },
      },
      TEST = { icon = " ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      AWE = {
        icon = "󰱫 ",
        color = "test",
        alt = { "COOL", "GOOD", "AWESOME", "Answer" },
      },
      SX = {
        icon = "󰍩 ",
        color = "default",
        alt = {
          "symptoms",
          "sx",
          "Clinical manifestations",
          "Presentations",
          "presentations",
          "Sx",
          "Overview",
        },
      },
    },
  },
  -- config = function()
  -- 	vim.keymap.set("n", "]t", function()
  -- 		require("todo-comments").jump_next()
  -- 	end, { desc = "Next todo comment" })
  --
  -- 	vim.keymap.set("n", "[t", function()
  -- 		require("todo-comments").jump_prev()
  -- 	end, { desc = "Previous todo comment" })
  --
  -- 	-- You can also specify a list of valid jump keywords
  --
  -- 	vim.keymap.set("n", "]t", function()
  -- 		require("todo-comments").jump_next({ keywords = { "ERROR", "WARNING" } })
  -- 	end, { desc = "Next error/warning todo comment" })
  -- end,
}
