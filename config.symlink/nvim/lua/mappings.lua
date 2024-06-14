require "nvchad.mappings"

local vim = vim
local map = vim.keymap.set

-- normal mode --
map("n", ";", ":", { desc = "CMD enter command mode" })
map("n", "c", '"_c', { desc = "To Black Hole" })
map("n", "+", "<C-a>", { desc = "increase number" })
map("n", "_", "<C-x>", { desc = "decrease number" })
map("n", "x", '"_x', { desc = "do not yank x when x", nowait = true })
map("n", "H", "^", { desc = "Beginning of line" })
map("n", "L", "$", { desc = "End of line" })
map("n", "<Right>", ":bn<CR>", { desc = "Next buffer" })
map("n", "<Left>", ":bp<CR>", { desc = "Previous buffer" })
map("n", "<Down>", ":tabnext<CR>", { nowait = true, silent = true })
map("n", "<Up>", ":tabprevious<CR>", { nowait = true, silent = true })
map("n", "<ESC>", ":", { desc = "Enter Cmdline" })
map("n", "?", ":noh<CR>", { desc = "Delete Highlight", silent = true })
map("n", "<leader>ta", ":tabnew<CR>", { desc = "New Tab", nowait = true, silent = true })
map("n", "<leader>w", ":w ++p ++bad=drop<CR>", { desc = "Save" })
map("n", "<leader>q", ":q<CR>", { desc = "Quit" })
map("n", "<C-c>", "<ESC>", { desc = "Map Ctrl + C to True Esc" })
map("n", "<C-s>", "<cmd>SymbolsOutline<CR>", { desc = "Symbols Outline", nowait = true, silent = true })
map("n", "j", function() -----------------
  return vim.v.count > 0 and "j" or "gj"
end, { expr = true })
map("n", "k", function() -----------------
  return vim.v.count > 0 and "k" or "gk"
end, { expr = true })
map("n", "dd", function() -----------------
  if vim.fn.getline "." == "" then
    return '"_dd'
  end
  return "dd"
end, { expr = true })
map("n", "<C-P>", "<cmd>put<CR>", { desc = "Paste Below", nowait = true, silent = true })
map("n", "<leader>i", function() -----------------
  vim.cmd "startinsert"
  os.execute "im-select com.boshiamy.inputmethod.BoshiamyIMK"
  print "切換為嘸蝦米輸入法！"
end, { desc = "when go into the insert mode, switch to boshiamy.inputmethod", nowait = true, silent = true })

-- insert mode --
map("i", "<C-c>", "<ESC>", { desc = "Escape" })

-- visual mode --
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })
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
