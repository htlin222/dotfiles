-- 操作符模式按鍵映射
local function map(modes, lhs, rhs, opts)
  opts.silent = opts.silent ~= false
  opts.nowait = opts.nowait ~= false
  vim.keymap.set(modes, lhs, rhs, opts)
end

return function()
  -- 文本對象快捷鍵
  map("o", "ii", 'i"', { desc = 'inner "' })
  map("o", "io", "i'", { desc = "inner '" })
  map("o", "ih", "i(", { desc = "inner (" })
  map("o", "ij", "i[", { desc = "inner [" })
  map("o", "ik", "i{", { desc = "inner {" })
  map("o", "il", "i<", { desc = "inner <" })
  map("o", "iq", "i`", { desc = "inner `" })
  map("o", "ai", 'a"', { desc = 'inner "' })
  map("o", "ao", "a'", { desc = "inner '" })
  map("o", "ah", "a(", { desc = "inner (" })
  map("o", "aj", "a[", { desc = "inner [" })
  map("o", "ak", "a{", { desc = "inner {" })
  map("o", "al", "a<", { desc = "inner <" })
  map("o", "aq", "a`", { desc = "inner `" })
end