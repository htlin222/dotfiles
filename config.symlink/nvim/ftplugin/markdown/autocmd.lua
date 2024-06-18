local vim = vim
-- 定義自動命令組
vim.api.nvim_create_augroup("creatprevious", {})

-- 添加自動命令到組
vim.api.nvim_create_autocmd("BufLeave", {
  pattern = "*.md",
  callback = function()
    vim.g.previous = vim.fn.expand "%:t:r"
  end,
  group = "creatprevious",
})
