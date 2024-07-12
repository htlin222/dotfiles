local vim = vim
return {
  "ThePrimeagen/harpoon",
  event = "VeryLazy",
  config = function()
    local map = vim.keymap.set
    -- normal mode --
    map("n", "<leader>jj", function()
      require("harpoon.mark").add_file()
      print "+ added to harpoon🦈"
    end, { desc = "harppon add mark file", nowait = true, silent = false })
    map("n", "<leader>kk", function()
      require("harpoon.ui").toggle_quick_menu()
    end, { desc = "harppon toggle_quick_menu", nowait = true, silent = false })

    map("n", "<leader>jk", function()
      require("harpoon.ui").nav_next()
    end, { desc = "harppon nav_next", nowait = true, silent = false })
    map("n", "<leader>kj", function()
      require("harpoon.ui").nav_prev()
    end, { desc = "harppon nav_prev", nowait = true, silent = false })
  end,
}
