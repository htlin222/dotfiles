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
  event = { "InsertEnter" },
  -- event = { "VeryLazy" },
  opts = {
    performance = {
      max_view_entries = 15,
    },
    window = {
      completion = cmp.config.window.bordered(nil),
      documentation = cmp.config.window.bordered(nil),
    },
    sources = {
      {
        name = "nvim_lsp",
        option = {
          markdown_oxide = {
            keyword_pattern = [[\(\k\| \|\/\|#\)\+]],
          },
        },
      },
      { name = "codeium" },
      -- { name = "supermaven" },
      { name = "luasnip" },
      -- { name = "cmp_zotcite" },
      -- { name = "papis" },
      { name = "nvim_lsp_document_symbol" },
      { name = "nvim_lsp_signature_help" },
      { name = "otter" },
      { name = "plugins" },
      -- { name = "mkdnflow" },
      { name = "buffer" },
      { name = "bufname" },
      { name = "rg", keyword_length = 3 },
      -- { name = "omni",                    option = { disable_omnifuncs = { "v:lua.vim.lsp.omnifunc" } } },
      -- { name = "calc" },
      -- { name = "rpncalc" },
      { name = "cmdline_history" },
      { name = "nvim_lua" },
      { name = "treesitter" },
      { name = "async_path" },
      -- { name = "path" },
      { name = "cmp_yanky" },
      -- { name = "cmp_tabnine" },
      { name = "emoji" },
      { name = "pandoc_references" },
      { name = "treesitter" },
      -- { name = "cmp_r" },
      -- { name = "buffer-lines",            option = {} },
      {
        name = "look",
        keyword_length = 3,
        option = {
          convert_case = true,
          loud = true,
        },
      },
    },
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
          cmp.select_next_item()
        -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
        -- they way you will only jump inside the snippet region
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
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<C-j>"] = require("cmp").mapping(function(fallback)
        if require("luasnip").choice_active() then
          require("luasnip").change_choice(1)
        else
          fallback()
        end
      end, {
        "i",
        "s",
      }),
      ["<C-k>"] = require("cmp").mapping(function(fallback)
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
        local kind = require("lspkind").cmp_format { mode = "symbol_text", maxwidth = 50 }(entry, vim_item)
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
        return vim_item
      end,
    },
    -- End of options
  },

  dependencies = {
    { "hrsh7th/cmp-emoji" },
    { "Exafunction/codeium.nvim" },
    { "FelipeLema/cmp-async-path" },
    -- { "jalvesaq/zotcite" },
    { "amarakon/nvim-cmp-buffer-lines" },
    { "lukas-reineke/cmp-rg" },
    -- { "jalvesaq/cmp-nvim-r" },
    -- { "jalvesaq/Nvim-R" },
    { "R-nvim/cmp-r" },
    { "chrisgrieser/cmp_yanky" },
    { "octaltree/cmp-look" },
    { "onsails/lspkind.nvim" },
    { "ray-x/cmp-treesitter" },
    { "jc-doyle/cmp-pandoc-references" },
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
