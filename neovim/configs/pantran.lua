return { --
  "potamides/pantran.nvim",
  -- lazy = false,
  ft = { "markdown" },
  -- event = "VeryLazy",
  -- when enter a buffer
  -- event = { "BufReadPre " .. vim.fn.expand "~" .. "/Documents/Medical/**.md" },
  dependencies = {},
  config = function()
    require("pantran").setup({
      -- Default engine to use for translation. To list valid engine names run
      -- `:lua =vim.tbl_keys(require("pantran.engines"))`.
      default_engine = "google",
      -- Configuration for individual engines goes here.
      engines = {
        google = {
          default_target = "zh-TW",
        },
      },
      controls = {
        mappings = {
          edit = {
            n = {
              -- Use this table to add additional mappings for the normal mode in
              -- the translation window. Either strings or function references are
              -- supported.
              ["j"] = "gj",
              ["k"] = "gk",
            },
            i = {
              -- Similar table but for insert mode. Using 'false' disables
              -- existing keybindings.
              ["<C-y>"] = false,
              ["<C-a>"] = require("pantran.ui.actions").yank_close_translation,
            },
          },
          -- Keybindings here are used in the selection window.
          select = {
            n = {
              -- ...
            },
          },
        },
      },
    })
  end,
}
