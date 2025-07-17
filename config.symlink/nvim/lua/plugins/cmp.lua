local luasnip = require "luasnip"
local cmp = require "cmp"
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
  event = { "BufEnter" },
  opts = {
    performance = {
      max_view_entries = 15,
      debounce = 100, -- 增加防抖動時間
      throttle = 50, -- 限制觸發頻率
      fetching_timeout = 200, -- 設置獲取超時時間
    },
    window = {
      completion = cmp.config.window.bordered(nil),
      documentation = cmp.config.window.bordered(nil),
    },
    -- 優化：減少並優化completion sources，提升性能
    sources = cmp.config.sources({
      -- Group 1: Primary sources (always active)
      {
        name = "nvim_lsp",
        priority = 1000,
        max_item_count = 20,
        keyword_length = 3,
        option = {
          markdown_oxide = {
            keyword_pattern = [[\(\k\| \|\/\|#\)\+]],
          },
        },
      },
      { name = "luasnip", priority = 900, max_item_count = 15, keyword_length = 3 },
      { name = "nvim_lsp_signature_help", priority = 800, keyword_length = 3 },
      { name = "codeium", priority = 850, keyword_length = 3 },
      { name = "buffer", priority = 500, max_item_count = 10, keyword_length = 3 },
      { name = "async_path", priority = 400, max_item_count = 10, keyword_length = 3 },
    }, {
      -- Group 2: Secondary sources (when primary has few results)
      { name = "nvim_lua", priority = 600, ft = { "lua" }, keyword_length = 3 },
      { name = "emoji", priority = 350, keyword_length = 3 },
      { name = "cmp_yanky", priority = 340, max_item_count = 5, keyword_length = 3 },
      { name = "treesitter", priority = 300, max_item_count = 10, keyword_length = 3 },
      { name = "spell", priority = 330, max_item_count = 5, keyword_length = 3 },
      { name = "npm", priority = 320, keyword_length = 3, max_item_count = 5 },
    }, {
      -- Group 3: Heavy/slow sources (only when needed)
      { name = "buffer-lines", priority = 280, max_item_count = 5, keyword_length = 3 },
      { name = "rg", priority = 270, max_item_count = 5, keyword_length = 3 },
      {
        name = "look",
        priority = 200,
        keyword_length = 3,
        max_item_count = 5,
        option = {
          convert_case = true,
          loud = true,
        },
      },
    }),
    mapping = {
      ["<C-d>"] = require("cmp").mapping.scroll_docs(-4),
      ["<C-f>"] = require("cmp").mapping.scroll_docs(4),
      ["<C-i>"] = require("cmp").mapping.complete(),
      ["<C-e>"] = require("cmp").mapping.close(),
      ["<CR>"] = require("cmp").mapping.confirm {
        behavior = require("cmp").ConfirmBehavior.Insert,
        select = true,
      },
      -- ["<C-u>"] = cmp.mapping({
      -- 	i = function(fallback)
      -- 		if luasnip.choice_active() then
      -- 			require("luasnip.extras.select_choice")()
      -- 		else
      -- 			fallback()
      -- 		end
      -- 	end,
      -- }),
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
      ["<C-n>"] = require("cmp").mapping(function(fallback)
        if require("luasnip").choice_active() then
          require("luasnip").change_choice(1)
        else
          fallback()
        end
      end, {
        "i",
        "s",
      }),
      ["<C-p>"] = require("cmp").mapping(function(fallback)
        if require("luasnip").choice_active() then
          require("luasnip").change_choice(-1)
        else
          fallback()
        end
      end, {
        "i",
        "s",
      }),
    },
    formatting = {
      fields = { "kind", "abbr" },
      format = function(entry, vim_item)
        local kind = require("lspkind").cmp_format {
          mode = "symbol_text",
          maxwidth = 50,
          symbol_map = { Supermaven = "" },
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
        local highlights_info = require("colorful-menu").cmp_highlights(entry)

        -- highlight_info is nil means we are missing the ts parser, it's
        -- better to fallback to use default `vim_item.abbr`. What this plugin
        -- offers is two fields: `vim_item.abbr_hl_group` and `vim_item.abbr`.
        if highlights_info ~= nil then
          vim_item.abbr_hl_group = highlights_info.highlights
          vim_item.abbr = highlights_info.text
        end
        return vim_item
      end,
    },
    -- End of options
  },
  config = function(_, opts)
    local cmp = require "cmp"
    cmp.setup(opts)

    -- Setup cmdline completion for '/'
    cmp.setup.cmdline("/", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },
      },
    })

    -- Setup cmdline completion for ':'
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
    { "hrsh7th/cmp-emoji" },
    { "Exafunction/codeium.nvim" },
    { "FelipeLema/cmp-async-path" },
    -- { "jalvesaq/zotcite" },
    { "amarakon/nvim-cmp-buffer-lines" },
    { "lukas-reineke/cmp-rg" },
    -- { "supermaven-inc/supermaven-nvim" },
    -- { "jalvesaq/cmp-nvim-r" },
    -- { "jalvesaq/Nvim-R" },
    { "R-nvim/cmp-r" },
    { "chrisgrieser/cmp_yanky" },
    { "octaltree/cmp-look" },
    { "onsails/lspkind.nvim" },
    { "ray-x/cmp-treesitter" },
    { "jc-doyle/cmp-pandoc-references" },
    { "f3fora/cmp-spell" },
    { "David-Kunz/cmp-npm" },
    { "hrsh7th/cmp-cmdline" },
    { -- [aspeddro/cmp-pandoc.nvim: Pandoc source for nvim-cmp](https://github.com/aspeddro/cmp-pandoc.nvim)
      "aspeddro/cmp-pandoc.nvim",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "jbyuki/nabla.nvim", -- optional
      },
      configs = function()
        require("cmp_pandoc").setup {}
      end,
    },
    {
      "KadoBOT/cmp-plugins",
      config = function()
        require("cmp-plugins").setup {
          files = { ".*\\.lua" }, -- default
          -- files = { "plugins.lua", "some_path/plugins/" } -- Recommended: use static filenames or partial paths
        }
      end,
    },
  },
}
