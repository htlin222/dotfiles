return {
  "epwalsh/obsidian.nvim",
  -- lazy = true,
  event = { "BufReadPre " .. vim.fn.expand("~") .. "/Documents/Medical/**.md" },
  -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand':
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
    "nvim-telescope/telescope.nvim",
    "godlygeek/tabular",
    "preservim/vim-markdown",
  },
  opts = {
    dir = "~/Documents/Medical/", -- no need to call 'vim.fn.expand' here
    disable_frontmatter = true,
    templates = {
      subdir = "template",
      date_format = "%Y-%m-%d-%a",
      time_format = "%H:%M",
    },
    -- see below for full list of options 👇
  },
  config = function(_, opts)
    require("obsidian").setup(opts)

    -- Optional, override the 'gf' keymap to utilize Obsidian's search functionality.
    -- see also: 'follow_url_func' config option below.
    vim.keymap.set("n", "gf", function()
      if require("obsidian").util.cursor_on_markdown_link() then
        return "<cmd>ObsidianFollowLink<CR>"
      else
        return "gf"
      end
    end, { noremap = false, expr = true })
  end,
}
