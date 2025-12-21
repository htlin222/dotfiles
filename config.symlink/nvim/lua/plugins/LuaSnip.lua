-- 優化：移除頂層 require，延遲載入 snippets
local vim = vim
return { --LuaSnip
  "L3MON4D3/LuaSnip",
  dependencies = "rafamadriz/friendly-snippets",
  event = { "InsertEnter" },
  build = { "make install_jsregexp" },
  opts = { history = true, updateevents = "TextChanged,TextChangedI" },
  config = function()
    local ls = require "luasnip"
    -- 延遲載入 snippets，避免阻塞啟動
    vim.schedule(function()
      require "lua_snippets"
    end)
    vim.keymap.set({ "i", "s" }, "<C-L>", function()
      ls.jump(1)
    end, { silent = true })
    vim.keymap.set({ "i", "s" }, "<C-H>", function()
      ls.jump(-1)
    end, { silent = true })
  end,
}
