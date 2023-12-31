return{ "nvim-telescope/telescope-bibtex.nvim",
  ft = {"markdown"},
  cmd = {'Telescope bibtex'},
  dependencies = {
    {'nvim-telescope/telescope.nvim'},
  },
  config = function ()
    require"telescope".load_extension("bibtex")
  end,
}
