-- 視覺模式按鍵映射
local function map(modes, lhs, rhs, opts)
  opts.silent = opts.silent ~= false
  opts.nowait = opts.nowait ~= false
  vim.keymap.set(modes, lhs, rhs, opts)
end

return function()
  -- 基本編輯
  map("v", "<", "<gv", { desc = "Indent left" })
  map("v", ">", ">gv", { desc = "Indent right" })
  map("v", ";", ":", { desc = "enter command mode", silent = false })
  map("v", "p", '"_dP', { desc = "paste but don't overwrite the clipboard" })

  -- 導航
  map("v", "L", "$h", { desc = "go to end of line" })
  map("v", "H", "^", { desc = "begining of line" })

  -- 移動選中的文本
  map("v", "J", ":m '>+1<CR>gv=gv", { desc = "move the selection down" })
  map("v", "K", ":m '<-2<CR>gv=gv", { desc = "move the selection up" })

  -- 文本對象快捷鍵
  map("v", "ih", "i(", { desc = "same as i[" })
  map("v", "ij", "i[", { desc = "same as i[" })
  map("v", "ik", "i{", { desc = "same as i{" })
  map("v", "im", "i'", { desc = "same as i'" })
  map("v", "i,", 'i"', { desc = 'same as i"' })
  map("v", "aj", "a[", { desc = "same as a[" })
  map("v", "ak", "a{", { desc = "same as a{" })
  map("v", "ah", "a<", { desc = "same as a<" })
  map("v", "am", "a'", { desc = "same as a'" })
  map("v", "a,", 'a"', { desc = 'same as a"' })

  -- AI 補全
  map("v", "<leader>ga", ":'<,'>!aicomp<cr>", { desc = "Aider Append" })

  -- 複製帶上下文
  map(
    "v",
    "<leader>y",
    ":lua require('func').yank_with_context()<CR>",
    { desc = "Yank selection with file path and line numbers" }
  )
end

