return { --hop
  -- upstream moved: phaazon/hop.nvim was deleted, smoka7 is the live fork
  "smoka7/hop.nvim",
  -- lazy = false,
  keys = "f",
  -- event = "VeryLazy",
  -- no v2 branch on the fork; master is the maintained line
  config = function()
    -- you can configure Hop the way you like here; see :h hop-config
    require("hop").setup {
      keys = "fjdkslqprueiwovmc",
      case_insensitive = true,
      quit_key = "<SPC>",
      vim.api.nvim_set_keymap("n", "f", ":HopChar2<CR>", { noremap = true, silent = true }),
    }
  end,
}
