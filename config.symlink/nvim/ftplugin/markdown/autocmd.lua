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

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  callback = function()
    local line_count = vim.api.nvim_buf_line_count(0)
    local target_line = math.min(10, line_count)
    vim.api.nvim_win_set_cursor(0, { target_line, 0 })
  end,
})
