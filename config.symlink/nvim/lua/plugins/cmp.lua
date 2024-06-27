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
  event = { "VeryLazy", "InsertEnter" },
  opts = {
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
      { name = "luasnip" },
      -- { name = "cmp_zotcite" },
      -- { name = "papis" },
      { name = "nvim_lsp_document_symbol" },
      { name = "nvim_lsp_signature_help" },
      { name = "otter" },
      { name = "mkdnflow" }, -- Add this
      { name = "buffer" },
      { name = "bufname" },
      -- { name = "rg", keyword_length = 5 },
      -- { name = "omni",                    option = { disable_omnifuncs = { "v:lua.vim.lsp.omnifunc" } } },
      -- { name = "calc" },
      -- { name = "rpncalc" },
      { name = "cmdline_history" },
      { name = "nvim_lua" },
      { name = "path" },
      { name = "cmp_yanky" },
      -- { name = "cmp_tabnine" },
      { name = "emoji" },
      { name = "cmp_nvim_r" },
      { name = "pandoc_references" },
      { name = "treesitter" },
      -- { name = "cmp_r" },
      -- { name = "buffer-lines",            option = {} },
      {
        name = "spell",
        option = {
          keep_all_entries = false,
          enable_in_context = function()
            return true
          end,
        },
      },
      -- { name = "dictionary",       keyword_length = 2 },
    },
    mapping = {
      ["<C-d>"] = require("cmp").mapping.scroll_docs(-4),
      ["<C-f>"] = require("cmp").mapping.scroll_docs(4),
      ["<C-Space>"] = require("cmp").mapping.complete(),
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
      format = function(_, vim_item)
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
    -- { "jalvesaq/zotcite" },
    { "amarakon/nvim-cmp-buffer-lines" },
    { "lukas-reineke/cmp-rg" },
    { "jalvesaq/cmp-nvim-r" },
    { "jalvesaq/Nvim-R" },
    { "R-nvim/cmp-r" },
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

    { -- setting of tabnine : [tzachar/cmp-tabnine: TabNine plugin for hrsh7th/nvim-cmp](https://github.com/tzachar/cmp-tabnine)
      -- "tzachar/cmp-tabnine",
      -- build = "./install.sh",
      -- config = function()
      -- 	local tabnine = require("cmp_tabnine.config")
      -- 	tabnine:setup({}) -- put your options here
      -- end,
    },
    { -- setting of cmp_ai : see : [tzachar/cmp-ai](https://github.com/tzachar/cmp-ai)
      -- "tzachar/cmp-ai",
      -- config = function()
      -- 	local cmp_ai = require("cmp_ai.config")
      -- 	cmp_ai:setup({
      -- 		max_lines = 1000,
      -- 		provider = "OpenAI",
      -- 		model = "gpt-4",
      -- 		notify = true,
      -- 		run_on_every_keystroke = true,
      -- 		ignored_file_types = {
      -- 			-- default is not to ignore
      -- 			-- uncomment to ignore in lua:
      -- 			-- lua = true
      -- 		},
      -- 	})
      -- end,
    },
  },
}
