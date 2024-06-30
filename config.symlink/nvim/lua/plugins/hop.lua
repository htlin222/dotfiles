return { --hop
  "phaazon/hop.nvim",
  -- lazy = false,
  keys = "f",
  -- event = "VeryLazy",
  branch = "v2", -- optional but strongly recommended
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
