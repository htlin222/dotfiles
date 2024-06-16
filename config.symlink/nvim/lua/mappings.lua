require "nvchad.mappings"

local vim = vim
local map = vim.keymap.set

-- normal mode --
map("n", ";", ":", { desc = "CMD enter command mode", nowait = true, silent = true })
map("n", "c", '"_c', { desc = "To Black Hole", silent = true })
map("n", "+", "<C-a>", { desc = "increase number", nowait = true })
map("n", "_", "<C-x>", { desc = "decrease number", nowait = true })
map("n", "x", '"_x', { desc = "do not yank x when x", nowait = true })
map("n", "H", "^", { desc = "Beginning of line", nowait = true })
map("n", "L", "$", { desc = "End of line", nowait = true })
map("n", "<Right>", ":bn<CR>", { desc = "Next buffer", nowait = true, silent = true })
map("n", "<Left>", ":bp<CR>", { desc = "Previous buffer", nowait = true, silent = true })
map("n", "<Down>", ":tabnext<CR>", { nowait = true, silent = true })
map("n", "<Up>", ":tabprevious<CR>", { nowait = true, silent = true })
map("n", "<ESC>", ":", { desc = "Enter Cmdline" })
map("n", "?", ":noh<CR>", { desc = "Delete Highlight", silent = true })
map("n", "<leader>ta", ":tabnew<CR>", { desc = "New Tab", nowait = true, silent = true })
map("n", "<leader>w", ":w ++p ++bad=drop<CR>", { desc = "Save", nowait = true, silent = true })
map("n", "<leader>q", ":q<CR>", { desc = "Quit", nowait = true, silent = true })
map("n", "<C-c>", "<ESC>", { desc = "Map Ctrl + C to True Esc", silent = true })
map("n", "<C-s>", "<cmd>SymbolsOutline<CR>", { desc = "Symbols Outline", nowait = true, silent = true })
map("n", "j", function() -----------------
  return vim.v.count > 0 and "j" or "gj"
end, { expr = true, nowait = true, silent = true })
map("n", "k", function() -----------------
  return vim.v.count > 0 and "k" or "gk"
end, { expr = true, nowait = true, silent = true })
map("n", "dd", function() -----------------
  if vim.fn.getline "." == "" then
    return '"_dd'
  end
  return "dd"
end, { expr = true, silent = true })
map("n", "<C-P>", "<cmd>put<CR>", { desc = "Paste Below", nowait = true, silent = true })

map("n", "<leader><CR>", function()
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
end, { desc = "Paste Below", nowait = true, silent = true })
map("n", "<leader>i", function() -----------------
  vim.cmd "startinsert"
  os.execute "im-select com.boshiamy.inputmethod.BoshiamyIMK"
  print "切換為嘸蝦米輸入法！"
end, { desc = "when go into the insert mode, switch to boshiamy.inputmethod", nowait = true, silent = true })

-- insert mode --
map("i", "<C-c>", "<ESC>", { desc = "Escape", nowait = true })

-- visual mode --
map("v", "<", "<gv", { desc = "Indent left", nowait = true })
map("v", ">", ">gv", { desc = "Indent right", nowait = true })
map("v", ";", ":", { desc = "enter command mode", nowait = true })
map("v", "<leader>ga", ":'<,'>!aicomp<cr>", { desc = "Aider Append", nowait = true })
map("v", "p", '"_dP', { desc = "paste but don't overwrite the clipboard", nowait = true })
map("v", "ij", "i[", { desc = "same as i[", nowait = true })
map("v", "ik", "i{", { desc = "same as i{", nowait = true })
map("v", "ih", "i<", { desc = "same as i<", nowait = true })
map("v", "im", "i'", { desc = "same as i'", nowait = true })
map("v", "i,", 'i"', { desc = 'same as i"', nowait = true })
map("v", "aj", "a[", { desc = "same as a[", nowait = true })
map("v", "ak", "a{", { desc = "same as a{", nowait = true })
map("v", "ah", "a<", { desc = "same as a<", nowait = true })
map("v", "am", "a'", { desc = "same as a'", nowait = true })
map("v", "a,", 'a"', { desc = 'same as a"', nowait = true })
map("v", "L", "$h", { desc = "go to end of line", nowait = true })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "move the selection down", nowait = true })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "move the selection up", nowait = true })
map("v", "H", "^", { desc = "begining of line", nowait = true })
