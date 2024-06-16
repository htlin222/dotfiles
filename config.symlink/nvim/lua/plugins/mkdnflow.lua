return { --mkdnflow
  "jakewvincent/mkdnflow.nvim",
  ft = { "markdown", "quarto" },
  -- lazy = true,
  config = function()
    -- by default, the fold method was set by tree-sitter expr
    vim.opt.foldmethod = "manual"
    vim.opt.foldlevel = 3
    vim.cmd "source $HOME/.config/nvim/lua/func/mdfmt.vim"
    vim.cmd "source $HOME/.config/nvim/lua/func/mdmain.vim"
    require("mkdnflow").setup {
      modules = {
        bib = false,
        buffers = true,
        conceal = true,
        cursor = true,
        folds = false,
        links = true,
        lists = true,
        maps = true,
        paths = true,
        tables = true,
        yaml = false,
      },
      filetypes = { md = true, rmd = true, markdown = true, telekasten = true, vimiwki = true },
      perspective = {
        priority = "current",
        fallback = "root",
        root_tell = "~/Dropbox/Medical/",
        nvim_wd_heel = false,
        update = false,
      },
      wrap = true,
      silent = false,
      links = {
        style = "wiki",
        -- name_is_source = true,
        conceal = true,
        context = 0,
        implicit_extension = nil,
        transform_implicit = function(text)
          text = text:gsub("%s+$", "")
          return text
        end,
        transform_explicit = function(text)
          text = text:gsub("%s+$", "")
          text = text:gsub(" ", "_")
          text = text:lower()
          -- text = os.date('%Y-%m-%d_')..text
          return text
        end,
      },
      to_do = {
        symbols = { " ", "x", "X" },
        update_parents = true,
        not_started = " ",
        in_progress = "x",
        complete = "X",
      },
      create_dirs = true,
    }
  end,
}
