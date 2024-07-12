return {
  "hedyhli/markdown-toc.nvim",
  ft = "markdown", -- Lazy load on markdown filetype
  cmd = { "Mtoc" }, -- Or, lazy load on "Mtoc" command
  opts = {
    -- Your configuration here (optional)
    fences = {
      enabled = true,
      -- These fence texts are wrapped within "<!-- % -->", where the '%' is
      -- substituted with the text.
      start_text = "toc-start",
      end_text = "toc-end",
      -- An empty line is inserted on top and below the ToC list before the being
      -- wrapped with the fence texts, same as vim-markdown-toc.
    },
    toc_list = {
      -- string or list of strings (for cycling)
      -- If cycle_markers = false and markers is a list, only the first is used.
      -- You can set to '1.' to use a automatically numbered list for ToC (if
      -- your markdown render supports it).
      -- Example config for cycling markers:
      markers = "-",
      cycle_markers = false,
    },
  },
}
