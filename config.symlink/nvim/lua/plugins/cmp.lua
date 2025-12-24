-- 優化：移除頂層 require，改為延遲載入
local vim = vim
local ELLIPSIS_CHAR = "…"
local MAX_LABEL_WIDTH = 20
local MIN_LABEL_WIDTH = 20

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
end

return { -- this table will override the default cmp setting
  "hrsh7th/nvim-cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  opts = function()
    local cmp = require "cmp"
    local luasnip = require "luasnip"
    return {
      performance = {
        max_view_entries = 15,
        debounce = 100,
        throttle = 50,
        fetching_timeout = 200,
      },
      window = {
        completion = cmp.config.window.bordered(nil),
        documentation = cmp.config.window.bordered(nil),
      },
      sources = cmp.config.sources({
        -- 高優先級：核心補全
        {
          name = "nvim_lsp",
          priority = 1000,
          max_item_count = 20,
          keyword_length = 2,
          option = {
            markdown_oxide = {
              keyword_pattern = [[\(\k\| \|\/\|#\)\+]],
            },
          },
        },
        { name = "luasnip", priority = 900, max_item_count = 15, keyword_length = 2 },
        { name = "codeium", priority = 850, keyword_length = 2 },
        { name = "buffer", priority = 500, max_item_count = 10, keyword_length = 3 },
        { name = "async_path", priority = 400, max_item_count = 10, keyword_length = 2 },
      }, {
        -- 中優先級：輔助補全
        { name = "nvim_lua", priority = 600, ft = { "lua" }, keyword_length = 2 },
        { name = "emoji", priority = 350, keyword_length = 2 },
        { name = "cmp_yanky", priority = 340, max_item_count = 5, keyword_length = 3 },
        { name = "spell", priority = 330, max_item_count = 5, keyword_length = 4 },
      }),
      mapping = {
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-i>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.close(),
        ["<CR>"] = cmp.mapping.confirm {
          behavior = cmp.ConfirmBehavior.Insert,
          select = true,
        },
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item { behavior = cmp.SelectBehavior.Insert }
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item { behavior = cmp.SelectBehavior.Insert }
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<C-n>"] = cmp.mapping(function(fallback)
          if luasnip.choice_active() then
            luasnip.change_choice(1)
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<C-p>"] = cmp.mapping(function(fallback)
          if luasnip.choice_active() then
            luasnip.change_choice(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      },
      formatting = {
        fields = { "kind", "abbr" },
        format = function(entry, vim_item)
          local kind = require("lspkind").cmp_format {
            mode = "symbol_text",
            maxwidth = 50,
            symbol_map = { Supermaven = "" },
          }(entry, vim_item)
          local strings = vim.split(kind.kind, "%s", { trimempty = true })
          kind.kind = " " .. (strings[1] or "") .. " "
          local label = vim_item.abbr
          local truncated_label = vim.fn.strcharpart(label, 0, MAX_LABEL_WIDTH)
          if truncated_label ~= label then
            vim_item.abbr = truncated_label .. ELLIPSIS_CHAR
          elseif string.len(label) < MIN_LABEL_WIDTH then
            local padding = string.rep(" ", MIN_LABEL_WIDTH - string.len(label))
            vim_item.abbr = label .. padding
          end
          local ok, colorful_menu = pcall(require, "colorful-menu")
          if ok then
            local highlights_info = colorful_menu.cmp_highlights(entry)
            if highlights_info ~= nil then
              vim_item.abbr_hl_group = highlights_info.highlights
              vim_item.abbr = highlights_info.text
            end
          end
          return vim_item
        end,
      },
    }
  end,
  config = function(_, opts)
    local cmp = require "cmp"
    cmp.setup(opts)

    cmp.setup.cmdline("/", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },
      },
    })

    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = "path" },
      }, {
        {
          name = "cmdline",
          option = {
            ignore_cmds = { "Man", "!" },
          },
        },
      }),
    })
  end,

  dependencies = {
    -- 核心補全
    { "hrsh7th/cmp-emoji" },
    { "Exafunction/codeium.nvim" },
    { "FelipeLema/cmp-async-path" },
    { "chrisgrieser/cmp_yanky" },
    { "onsails/lspkind.nvim" },
    { "f3fora/cmp-spell" },
    { "hrsh7th/cmp-cmdline" },
    -- 學術寫作支持
    { "R-nvim/cmp-r" },
    {
      "aspeddro/cmp-pandoc.nvim",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "jbyuki/nabla.nvim",
      },
      config = function()
        require("cmp_pandoc").setup {}
      end,
    },
  },
}
