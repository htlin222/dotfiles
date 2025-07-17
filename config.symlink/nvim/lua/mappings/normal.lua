-- 普通模式按鍵映射
local function map(modes, lhs, rhs, opts)
  opts.silent = opts.silent ~= false
  opts.nowait = opts.nowait ~= false
  vim.keymap.set(modes, lhs, rhs, opts)
end

return function()
  -- 基本導航和編輯
  map("n", ";", ":", { desc = "CMD enter command mode", silent = false })
  map("n", "c", '"_c', { desc = "To Black Hole", unique = false })
  map("n", "+", "<C-a>", { desc = "increase number" })
  map("n", "_", "<C-x>", { desc = "decrease number" })
  map("n", "x", '"_x', { desc = "do not yank x when x" })
  map("n", "H", "^", { desc = "Beginning of line" })
  map("n", "L", "$", { desc = "End of line" })
  map("n", "zj", "z=", { desc = "列出建議的修正選項" })
  
  -- 緩衝區和標籤頁導航
  map("n", "<Right>", ":bn<CR>", { desc = "Next buffer" })
  map("n", "<Left>", ":bp<CR>", { desc = "Previous buffer" })
  map("n", "<Down>", ":tabnext<CR>", { desc = "tab next" })
  map("n", "<Up>", ":tabprevious<CR>", { desc = "tab previous" })
  
  -- 文件路徑複製
  map("n", "<leader>yy", ':let @+ = expand("%:p")<CR>', { desc = "Yank current buffer file full path" })
  map("n", "<leader>yr", ':let @+ = expand("%:.")<CR>', { desc = "Yank current buffer file relative path" })
  map("n", "<leader>yp", ':let @+ = expand("%:h")<CR>', { desc = "Yank current buffer parent folder path" })
  map("n", "<leader>yw", ":let @+ = getcwd()<CR>", { desc = "Yank current working directory" })
  map("n", "<leader>yf", ':let @+ = expand("%:t")<CR>', { desc = "Yank current file name" })
  map("n", "<leader>yb", ':let @+ = expand("%:t:r")<CR>', { desc = "Yank current file name without extension" })
  
  -- 其他實用功能
  map("n", "<ESC>", ":", { desc = "Enter Cmdline" })
  map("n", "?", ":noh<CR>", { desc = "Delete Highlight" })
  map("n", "<leader>ta", ":tabnew<CR>", { desc = "New Tab" })
  map("n", "<leader>w", ":w ++p ++bad=drop<CR>", { desc = "Save" })
  map("n", "W", ":w ++p ++bad=drop<CR>", { desc = "Save" })
  map("n", "<leader>q", ":q<CR>", { desc = "Quit" })
  map("n", "<leader><TAB>", "i<CR><TAB>-<Space><ESC>$", { desc = "To sublist" })
  map("n", "<leader>=", "i<CR>-<Space><ESC>$", { desc = "Create a new list item till the end of of Line" })
  map("n", "gf", ":e <cfile><CR>", { desc = "gf new file" })
  map("n", "<leader><", "V`[<", { desc = "indent the pasted words" })
  map("n", "<leader>>", "V`]>", { desc = "redo indent the pasted words" })
  
  -- 文本轉換
  map("n", "<leader>fc", "<cmd>s/\\<\\(\\w\\)\\(\\S*\\)/\\u\\1\\L\\2/g<CR><cmd>noh<CR>", { desc = "Set The First Letter of Each Word Capital" })
  
  -- 特殊按鍵映射
  map("n", "<C-c>", "<ESC>", { desc = "Map Ctrl + C to True Esc" })
  map("n", "<C-P>", "<cmd>put<CR>", { desc = "Paste Below" })
  
  -- 智能移動
  map("n", "j", function()
    return vim.v.count > 0 and "j" or "gj"
  end, { expr = true })
  
  map("n", "k", function()
    return vim.v.count > 0 and "k" or "gk"
  end, { expr = true })
  
  -- 智能刪除行
  map("n", "dd", function()
    if vim.fn.getline "." == "" then
      return '"_dd'
    end
    return "dd"
  end, { expr = true })
  
  -- 雙擊 leader 鍵的功能
  map("n", "<leader><leader>", function()
    if vim.bo.filetype == "markdown" then
      local currentLine = vim.fn.getline "."
      local url = string.match(currentLine, "%(([^%)]+)%)")
      if url and (url:find "^zotero" or url:find "^skim" or url:find "^raycast") then
        vim.cmd("!open " .. vim.fn.fnameescape(url))
      else
        vim.fn.search "___"
        vim.cmd "echomsg '下一個空白'"
      end
    end
  end, { desc = "Paste Below" })
  
  -- 切換輸入法
  map("n", "<leader>i", function()
    vim.cmd "startinsert"
    local line_num = vim.api.nvim_win_get_cursor(0)[1] - 1
    vim.api.nvim_buf_set_extmark(0, vim.api.nvim_create_namespace "virtual_text", line_num, -1, {
      virt_text = { { " 嘸蝦米", "Comment" } },
      virt_text_pos = "eol",
    })
    os.execute "im-select com.boshiamy.inputmethod.BoshiamyIMK"
  end, { desc = "when go into the insert mode, switch to boshiamy.inputmethod" })
end