return {
  "supermaven-inc/supermaven-nvim",
  enabled = false,
  -- event = "VeryLazy",
  config = function()
    require("supermaven-nvim").setup {
      keymaps = {
        accept_suggestion = "<C-y>",
        clear_suggestion = "<C-c>",
        accept_word = "<C-n>",
      },
      -- color = {
      --   suggestion_color = "#f0f0f0",
      --   cterm = 144,
      -- },
      log_level = "info", -- set to "off" to disable logging completely
      disable_inline_completion = true, -- disables inline completion for use with cmp
      disable_keymaps = false, -- disables built in keymaps for more manual control
    }
  end,
}
