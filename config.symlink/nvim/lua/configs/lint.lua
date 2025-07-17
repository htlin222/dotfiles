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
    -- "codespell",
  },
  json = {
    "jsonlint",
    -- "eslint_d",
    -- "write_good",
  },
  javascriptreact = {
    -- "eslint_d",
    "quick-lint-js",
  },
  typescript = {
    "quick-lint-js",
  },
  markdown = {
    -- "codespell",
    -- "proselint",
    "vale",
    -- "typos",
    -- "write_good",
  },
  vim = { "vint" },
  bash = {
    "shellcheck",
  },
}

local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

-- 創建防抖動的 lint 函數
local timer = nil
local function debounced_lint()
  if timer then
    vim.fn.timer_stop(timer)
  end
  timer = vim.fn.timer_start(500, function()
    lint.try_lint(nil, { ignore_errors = true })
    timer = nil
  end)
end

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  group = lint_augroup,
  callback = function()
    -- 檢查文件大小，避免對大文件進行 lint
    local file_size = vim.fn.getfsize(vim.fn.expand "%")
    if file_size > 1024 * 1024 * 10 then -- 10MB
      return
    end
    debounced_lint()
  end,
})

vim.keymap.set("n", "<leader>ll", function()
  lint.try_lint()
end, { desc = "Trigger linting for current file" })
