-- 載入 NvChad 的鍵位映射
if not vim.g.vscode then
  require "nvchad.mappings"
end
-- 引用全局 vim 變量
local vim = vim
-- 定義一個函數用於設置按鍵映射
local function map(modes, lhs, rhs, opts)
  -- opts.unique = opts.unique ~= false
  -- 設置默認選項為靜音模式
  opts.silent = opts.silent ~= false
  -- 設置默認選項為不等待模式
  opts.nowait = opts.nowait ~= false
  -- 使用 vim.keymap.set 設置按鍵映射
  vim.keymap.set(modes, lhs, rhs, opts)
end
-- 普通模式按鍵映射 --
map("n", ";", ":", { desc = "CMD enter command mode", silent = false }) -- 使用分號進入命令模式
map("n", "c", '"_c', { desc = "To Black Hole", unique = false }) -- 使用 c 刪除時不複製到剪貼板
map("n", "+", "<C-a>", { desc = "increase number" }) -- 使用加號增加數字
map("n", "_", "<C-x>", { desc = "decrease number" }) -- 使用下劃線減少數字
map("n", "x", '"_x', { desc = "do not yank x when x" }) -- 使用 x 刪除時不複製到剪貼板
map("n", "H", "^", { desc = "Beginning of line" }) -- 使用 H 跳到行首
map("n", "L", "$", { desc = "End of line" }) -- 使用 L 跳到行尾
map("n", "<Right>", ":bn<CR>", { desc = "Next buffer" }) -- 使用右箭頭切換到下一個緩衝區
map("n", "<Left>", ":bp<CR>", { desc = "Previous buffer" }) -- 使用左箭頭切換到上一個緩衝區
map("n", "<leader>yy", ':let @+ = expand("%:p")<CR>', { desc = "Yank current buffer file full path" })
map("n", "<leader>yr", ':let @+ = expand("%:.")<CR>', { desc = "Yank current buffer file relative path" })
map("n", "<leader>yp", ':let @+ = expand("%:h")<CR>', { desc = "Yank current buffer parent folder path" })
map("n", "<leader>yw", ":let @+ = getcwd()<CR>", { desc = "Yank current working directory" })
map("n", "<leader>yf", ':let @+ = expand("%:t")<CR>', { desc = "Yank current file name" })
map("n", "<leader>yb", ':let @+ = expand("%:t:r")<CR>', { desc = "Yank current file name without extension" })
map("n", "<Down>", ":tabnext<CR>", { desc = "tab next" }) -- 使用下箭頭切換到下一個標籤頁
map("n", "<Up>", ":tabprevious<CR>", { desc = "tab previous" }) -- 使用上箭頭切換到上一個標籤頁
map("n", "<ESC>", ":", { desc = "Enter Cmdline" }) -- 使用 ESC 進入命令行模式
map("n", "?", ":noh<CR>", { desc = "Delete Highlight" }) -- 使用問號取消搜索高亮
map("n", "<leader>ta", ":tabnew<CR>", { desc = "New Tab" }) -- 創建新標籤頁
map("n", "<leader>w", ":w ++p ++bad=drop<CR>", { desc = "Save" }) -- 保存文件，忽略錯誤
map("n", "W", ":w ++p ++bad=drop<CR>", { desc = "Save" }) -- 使用大寫 W 保存文件
map("n", "<leader>q", ":q<CR>", { desc = "Quit" }) -- 退出
map("n", "<leader><TAB>", "i<CR><TAB>-<Space><ESC>$", { desc = "To sublist" }) -- 創建子列表項
map("n", "<leader>=", "i<CR>-<Space><ESC>$", { desc = "Create a new list item till the end of of Line" }) -- 創建新列表項
map("n", "gf", ":e <cfile><CR>", { desc = "gf new file" }) -- 在新文件中打開游標下的文件名
map("n", "<leader><", "V`[<", { desc = "indent the pasted words" }) -- 縮進剛貼上的文本
map("n", "<leader>>", "V`]>", { desc = "redo indent the pasted words" }) -- 重新縮進剛貼上的文本
map("n", "yih", "yi(", { desc = "複製括號內內容，使用 h 代替 (" })
map("n", "yij", "yi[", { desc = "複製方括號內內容，使用 j 代替 [" })
map("n", "yik", "yi{", { desc = "複製花括號內內容，使用 k 代替 {" })
map("n", "dih", "di(", { desc = "刪除括號內內容，使用 h 代替 (" })
map("n", "dij", "di[", { desc = "刪除方括號內內容，使用 j 代替 [" })
map("n", "dik", "di{", { desc = "刪除花括號內內容，使用 k 代替 {" })
map("n", "cih", "ci(", { desc = "更改括號內內容，使用 h 代替 (" })
map("n", "cij", "ci[", { desc = "更改方括號內內容，使用 j 代替 [" })
map("n", "cik", "ci{", { desc = "更改花括號內內容，使用 k 代替 {" })
map("n", "dah", "da(", { desc = "刪除括號及其內容，使用 h 代替 (" })
map("n", "daj", "da[", { desc = "刪除方括號及其內容，使用 j 代替 [" })
map("n", "dak", "da{", { desc = "刪除花括號及其內容，使用 k 代替 {" })
map("n", "cah", "ca(", { desc = "更改括號及其內容，使用 h 代替 (" })
map("n", "caj", "ca[", { desc = "更改方括號及其內容，使用 j 代替 [" })
map("n", "cak", "ca{", { desc = "更改花括號及其內容，使用 k 代替 {" })
map( ---------------  -- 將每個單詞的首字母大寫
  "n",
  "<leader>fc",
  "<cmd>s/\\<\\(\\w\\)\\(\\S*\\)/\\u\\1\\L\\2/g<CR><cmd>noh<CR>",
  { desc = "Set The First Letter of Each Word Capital" }
) ---------------
map("n", "<C-c>", "<ESC>", { desc = "Map Ctrl + C to True Esc" }) -- 將 Ctrl+C 映射為真正的 ESC
map("n", "j", function() -----------------  -- 智能向下移動（考慮換行）
  return vim.v.count > 0 and "j" or "gj"
end, { expr = true })
map("n", "k", function() -----------------  -- 智能向上移動（考慮換行）
  return vim.v.count > 0 and "k" or "gk"
end, { expr = true })
map("n", "dd", function() -----------------  -- 智能刪除行（空行不複製）
  if vim.fn.getline "." == "" then
    return '"_dd'
  end
  return "dd"
end, { expr = true })
map("n", "<C-P>", "<cmd>put<CR>", { desc = "Paste Below" }) -- 在下方貼上

map("n", "<leader><leader>", function() -- 雙擊 leader 鍵的功能
  if vim.bo.filetype == "markdown" then
    local currentLine = vim.fn.getline "."
    local url = string.match(currentLine, "%(([^%)]+)%)")
    if url and (url:find "^zotero" or url:find "^skim" or url:find "^raycast") then
      vim.cmd("!open " .. vim.fn.fnameescape(url))
    else
      vim.fn.search "___" -- 使用 vim.fn.search 尋找下一個匹配項
      vim.cmd "echomsg '下一個空白'"
    end
  end
end, { desc = "Paste Below" })

map("n", "<leader>i", function()
  vim.cmd "startinsert"
  local line_num = vim.api.nvim_win_get_cursor(0)[1] - 1
  vim.api.nvim_buf_set_extmark(0, vim.api.nvim_create_namespace "virtual_text", line_num, -1, {
    virt_text = { { " 嘸蝦米", "Comment" } },
    virt_text_pos = "eol",
  })
  os.execute "im-select com.boshiamy.inputmethod.BoshiamyIMK"
end, { desc = "when go into the insert mode, switch to boshiamy.inputmethod" })

-- 插入模式按鍵映射 --
map("i", "<C-c>", "<ESC>", { desc = "Escape" }) -- 將 Ctrl+C 映射為 ESC

-- 視覺模式按鍵映射 --
map("v", "<", "<gv", { desc = "Indent left" }) -- 向左縮進並保持選擇
map("v", ">", ">gv", { desc = "Indent right" }) -- 向右縮進並保持選擇
map("v", ";", ":", { desc = "enter command mode", silent = false }) -- 使用分號進入命令模式
map("v", "<leader>ga", ":'<,'>!aicomp<cr>", { desc = "Aider Append" }) -- 使用 AI 補全選中文本
map("v", "p", '"_dP', { desc = "paste but don't overwrite the clipboard" }) -- 貼上但不覆蓋剪貼板
map("v", "ih", "i(", { desc = "same as i[" }) -- 選擇括號內內容，使用 h 代替 (
map("v", "ij", "i[", { desc = "same as i[" }) -- 選擇方括號內內容，使用 j 代替 [
map("v", "ik", "i{", { desc = "same as i{" }) -- 選擇花括號內內容，使用 k 代替 {
map("v", "im", "i'", { desc = "same as i'" }) -- 選擇單引號內內容，使用 m 代替 '
map("v", "i,", 'i"', { desc = 'same as i"' }) -- 選擇雙引號內內容，使用逗號代替 "
map("v", "aj", "a[", { desc = "same as a[" }) -- 選擇方括號及其內容，使用 j 代替 [
map("v", "ak", "a{", { desc = "same as a{" }) -- 選擇花括號及其內容，使用 k 代替 {
map("v", "ah", "a<", { desc = "same as a<" }) -- 選擇尖括號及其內容，使用 h 代替 <
map("v", "am", "a'", { desc = "same as a'" }) -- 選擇單引號及其內容，使用 m 代替 '
map("v", "a,", 'a"', { desc = 'same as a"' }) -- 選擇雙引號及其內容，使用逗號代替 "
map("v", "L", "$h", { desc = "go to end of line" }) -- 跳到行尾（不包括換行符）
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "move the selection down" }) -- 向下移動選中的文本
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "move the selection up" }) -- 向上移動選中的文本
map("v", "H", "^", { desc = "begining of line" }) -- 跳到行首

-- Lspsaga 插件按鍵映射 --
map("n", "<leader>lo", "<cmd>Lspsaga outline<CR>", { desc = "Lspsaga Code Outline" }) -- 顯示代碼大綱
map("n", "K", "<cmd>Lspsaga hover_doc<CR>", { desc = "Hover Doc" }) -- 顯示懸停文檔
map("n", "<leader>fd", "<cmd>ArenaToggle<CR>", { desc = "ArenaToggle", nowait = true, silent = false }) -- 切換 Arena 面板
