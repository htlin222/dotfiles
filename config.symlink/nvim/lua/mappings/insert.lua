-- 插入模式按鍵映射
local function map(modes, lhs, rhs, opts)
  opts.silent = opts.silent ~= false
  opts.nowait = opts.nowait ~= false
  vim.keymap.set(modes, lhs, rhs, opts)
end

return function()
  map("i", "<C-c>", "<ESC>", { desc = "Escape" })
end