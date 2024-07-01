return {
  "gaborvecsei/cryptoprice.nvim",
  keys = {
    { -- example for lazy-loading on keystroke
      "<leader>cy",
      "<cmd>lua require('cryptoprice').toggle()<CR>",
      mode = { "n", "o", "x" },
      desc = "Check Crypto Price",
    },
  },
  config = function()
    require("cryptoprice").setup {
      base_currency = "twd",
      crypto_list = { "bitcoin" },
      window_height = 10,
      window_width = 60,
    }
  end,
}
