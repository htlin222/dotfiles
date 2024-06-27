local vim = vim
return {
  "quarto-dev/quarto-nvim",
  dev = false,
  ft = { "python", "r", "R", "quarto" },
  dependencies = {
    {
      "jmbuhr/otter.nvim",
      dev = false,
      dependencies = {
        { "neovim/nvim-lspconfig" },
        { "jpalardy/vim-slime" },
      },
      opts = {
        buffers = {
          set_filetype = true,
        },
      },
    },
  },
  config = function()
    require("quarto").setup {
      debug = true,
      closePreviewOnExit = false,
      lspFeatures = {
        enabled = true,
        languages = { "r", "python" },
        chunks = "curly", -- 'curly' or 'all'
        diagnostics = {
          enabled = false,
          triggers = { "BufWritePost" },
        },
        completion = {
          enabled = true,
        },
      },
      codeRunner = {
        enabled = true,
        default_method = "slime", -- 'molten' or 'slime'
        -- ft_runners = { r = "vim-slime " }, -- filetype to runner, ie. `{ python = "molten" }`.
        -- Takes precedence over `default_method`
        never_run = { "yaml" }, -- filetypes which are never sent to a code runner
      },
      keymap = {
        hover = "K",
        definition = "gd",
        rename = "<leader>lR",
        references = "gr",
      },
    }
    vim.g.slime_target = "neovim"
    local runner = require "quarto.runner"
    vim.keymap.set("n", "<leader>pv", "<cmd>QuartoPreview<CR>", { desc = "preview", silent = true })
    vim.keymap.set("n", "<leader>rc", runner.run_cell, { desc = "run cell", silent = true })
    vim.keymap.set("n", "<localleader>ra", runner.run_above, { desc = "run cell and above", silent = true })
    vim.keymap.set("n", "<localleader>rA", runner.run_all, { desc = "run all cells", silent = true })
    vim.keymap.set("n", "<localleader>rl", runner.run_line, { desc = "run line", silent = true })
    vim.keymap.set("v", "<localleader>r", runner.run_range, { desc = "run visual range", silent = true })
    vim.keymap.set("n", "<localleader>RA", function()
      runner.run_all(true)
    end, { desc = "run all cells of all languages", silent = true })
  end,
}
