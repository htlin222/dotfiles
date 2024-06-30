return { --telescope
  "nvim-telescope/telescope.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "debugloop/telescope-undo.nvim",
  },
  opts = {
    extensions = {
      bibtex = {
        -- Depth for the *.bib file
        depth = 1,
        -- Custom format for citation label
        custom_formats = {
          { id = "pandoc", cite_marker = "[@%s]" },
          { id = "zotero_link", cite_marker = "[🔗link](zotero://select/items/@%s)" },
        },
        -- Format to use for citation label.
        -- format = "zotero_link",
        format = "pandoc",
        -- Try to match the filetype by default, or use 'plain'
        -- global_files = { "/Users/mac/Zotero/zotero_main.bib" },
        -- Define the search keys to use in the picker
        search_keys = { "author", "year", "title", "date" },
        -- Only use initials for the authors first name
        citation_trim_firstname = true,
        -- Max number of authors to write in the formatted citation
        -- following authors will be replaced by "et al."
        citation_max_auth = 1,
        -- Context awareness disabled by default
        context = true,
        -- Fallback to global/directory .bib files if context not found
        -- This setting has no effect if context = false
        context_fallback = true,
        -- Wrapping in the preview window is disabled by default
        wrap = false,
        citation_format = "[[{{label}}]]",
      },
    },

    defaults = { prompt_prefix = "  ", selection_caret = "  ", entry_prefix = " " },

    -- projects settings
    manual_mode = false,

    -- Methods of detecting the root directory. **"lsp"** uses the native neovim
    -- lsp, while **"pattern"** uses vim-rooter like glob pattern matching. Here
    -- order matters: if one is not detected, the other is used as fallback. You
    -- can also delete or rearangne the detection methods.
    detection_methods = { "lsp", "pattern" },

    -- All the patterns used to detect root dir, when **"pattern"** is in
    -- detection_methods
    patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },

    -- Table of lsp clients to ignore by name
    -- eg: { "efm", ... }
    ignore_lsp = {},

    -- Don't calculate root dir on specific directories
    -- Ex: { "~/.cargo/*", ... }
    exclude_dirs = {},

    -- Show hidden files in telescope
    show_hidden = false,

    -- When set to false, you will get a message when project.nvim changes your
    -- directory.
    silent_chdir = true,

    -- What scope to change the directory, valid options are
    -- * global (default)
    -- * tab
    -- * win
    scope_chdir = "global",

    -- Path where project.nvim will store the project history for use in
    -- telescope
    datapath = vim.fn.stdpath "data",
  },
}
