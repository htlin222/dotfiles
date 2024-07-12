local vim = vim
-----------------------------------------------------------
-- Autocommand functions
-----------------------------------------------------------

local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

-----------------------------------------------------------
-- Autocommand functions
-----------------------------------------------------------

-- ████ Insert Title according to the filetype █████

-- shell script template

autocmd("BufNewFile", {
  group = augroup("Shell", { clear = true }),
  pattern = "*.sh",
  callback = function()
    local title = vim.fn.fnamemodify(vim.fn.expand "%:r", ":t")
    local date = os.date "%Y-%m-%d"
    local lines = {
      "#!/bin/bash",
      '# title: "' .. title .. '"',
      "# author: Hsieh-Ting Lin",
      '# date: "' .. date .. '"',
      "# version: 1.0.0",
      "# description: ",
      "# --END-- #",
      "set -ue",
      "set -o pipefail",
      "trap \"echo 'END'\" EXIT",
      "",
      "",
    }
    vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
    vim.cmd "silent !chmod +x %"
  end,
})

-- python template

autocmd("BufNewFile", {
  group = augroup("Python", { clear = true }),
  pattern = "*.py",
  callback = function()
    local lines = {
      "#!/usr/bin/env python3",
      "# -*- coding: utf-8 -*-",
      "# title: " .. vim.fn.fnamemodify(vim.fn.expand "%:r", ":t"),
      "# author: Hsieh-Ting Lin, the Lizard 🦎",
      "# description: " .. vim.fn.fnamemodify(vim.fn.expand "%:r", ":t") .. " is a script about...",
      '# date: "' .. os.date "%Y-%m-%d" .. '"',
      "# --END-- #",
      "",
      "",
      "def main():",
      '    """Write Docstring."""',
      '    print("your code here")',
      "",
      "",
      'if __name__ == "__main__":',
      "    main()",
    }
    vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
    vim.cmd "silent !chmod +x %"
  end,
})

-- R template

autocmd("BufNewFile", {
  group = augroup("R", { clear = true }),
  pattern = "*.R",
  callback = function()
    local lines = {
      "# title: " .. vim.fn.fnamemodify(vim.fn.expand "%:r", ":t"),
      '# date: "' .. os.date "%Y-%m-%d" .. '"',
      '# description: " "',
      "# author: Hsieh-Ting Lin, the Lizard 🦎",
      "# --END-- #",
      "",
      '# install.packages("PACKAGE_NAME")',
      '# devtools::install_github("author/PROJECT")',
      "# library(ggplot2)",
      "renv::init()",
      "",
    }
    vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
    vim.cmd "silent !chmod +x %"
  end,
})
