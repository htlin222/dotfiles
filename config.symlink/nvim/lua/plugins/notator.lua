return {
  "c-dilks/notator.nvim",
  -- lazy-load on filetype
  ft = { "markdown" },
  opts = {
    tag_table = {
      { name = "TODO", color = "red" },
      { name = "FIXME", color = "yellow" },
      { name = "DONE", color = "lightgreen" },
    },
    -- boolean setting whether all tags should be the same width;
    -- if true, all tags will use the width of the largest tag
    fixed_width = false,
    -- additional keybindings
  },
}
