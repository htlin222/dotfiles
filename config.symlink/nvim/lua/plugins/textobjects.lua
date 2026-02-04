return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  event = "VeryLazy",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("nvim-treesitter-textobjects").setup {
      select = {
        lookahead = true,
        selection_modes = {
          ["@parameter.outer"] = "v", -- charwise
          ["@function.outer"] = "V", -- linewise
          ["@class.outer"] = "<c-v>", -- blockwise
        },
        include_surrounding_whitespace = true,
      },
    }

    local select = require("nvim-treesitter-textobjects.select").select_textobject
    -- Select keymaps
    vim.keymap.set({ "x", "o" }, "af", function() select("@function.outer", "textobjects") end, { desc = "outer function" })
    vim.keymap.set({ "x", "o" }, "if", function() select("@function.inner", "textobjects") end, { desc = "inner function" })
    vim.keymap.set({ "x", "o" }, "ac", function() select("@class.outer", "textobjects") end, { desc = "outer class" })
    vim.keymap.set({ "x", "o" }, "ic", function() select("@class.inner", "textobjects") end, { desc = "inner class" })
    vim.keymap.set({ "x", "o" }, "as", function() select("@local.scope", "locals") end, { desc = "language scope" })
  end,
}
