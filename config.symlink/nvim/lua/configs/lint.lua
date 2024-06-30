-- Run :MasonInstall eslint_d to install the eslint daemon package
local vim = vim
local lint = require "lint"
lint.linters_by_ft = {
  lua = {
    "selene",
    -- "codespell",
  },
  python = {
    "ruff",
    "mypy",
    -- "codespell",
  },
  markdown = {
    "codespell",
    "vale",
    "write_good",
  },
  vim = { "vint" },
  sh = {
    -- "shellcheck",
  },
}

local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  group = lint_augroup,
  callback = function()
    -- lint.try_lint()
    lint.try_lint(nil, { ignore_errors = true })
  end,
})

vim.keymap.set("n", "<leader>ll", function()
  lint.try_lint()
end, { desc = "Trigger linting for current file" })
