local vim = vim
local ls = require "luasnip"
return { --LuaSnip
  "L3MON4D3/LuaSnip",
  dependencies = "rafamadriz/friendly-snippets",
  event = { "InsertEnter" },
  build = { "make install_jsregexp" },
  opts = { history = true, updateevents = "TextChanged,TextChangedI" },
  config = function()
    require "lua_snippets"
    vim.keymap.set({ "i", "s" }, "<C-L>", function()
      ls.jump(1)
    end, { silent = true })
    vim.keymap.set({ "i", "s" }, "<C-H>", function()
      ls.jump(-1)
    end, { silent = true })
  end,
}
