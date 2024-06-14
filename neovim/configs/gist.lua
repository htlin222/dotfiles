return {
  {
    "Rawnly/gist.nvim",
    event = "VeryLazy",
    cmd = { "GistCreate", "GistCreateFromFile", "GistsList" },
    config = true,
  },
  -- `GistsList` opens the selected gif in a terminal buffer,
  -- nvim-unception uses neovim remote rpc functionality to open the gist in an actual buffer
  -- and prevents neovim buffer inception
  {
    "samjwill/nvim-unception",
    -- lazy = false,
    event = "VeryLazy",
    init = function()
      vim.g.unception_block_while_host_edits = true
    end,
  },
}
