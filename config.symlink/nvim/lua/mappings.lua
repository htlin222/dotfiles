require "nvchad.mappings"
local nio = require "nio"
local vim = vim
local function map(modes, lhs, rhs, opts)
  -- opts.unique = opts.unique ~= false
  opts.silent = opts.silent ~= false
  opts.nowait = opts.nowait ~= false
  vim.keymap.set(modes, lhs, rhs, opts)
end
-- normal mode --
map("n", ";", ":", { desc = "CMD enter command mode", silent = false })
map("n", "c", '"_c', { desc = "To Black Hole", unique = false })
map("n", "+", "<C-a>", { desc = "increase number" })
map("n", "_", "<C-x>", { desc = "decrease number" })
map("n", "x", '"_x', { desc = "do not yank x when x" })
map("n", "H", "^", { desc = "Beginning of line" })
map("n", "L", "$", { desc = "End of line" })
map("n", "<Right>", ":bn<CR>", { desc = "Next buffer" })
map("n", "<Left>", ":bp<CR>", { desc = "Previous buffer" })
map("n", "<Down>", ":tabnext<CR>", { desc = "tab next" })
map("n", "<Up>", ":tabprevious<CR>", { desc = "tab previous" })
map("n", "<ESC>", ":", { desc = "Enter Cmdline" })
map("n", "?", ":noh<CR>", { desc = "Delete Highlight" })
map("n", "<leader>ta", ":tabnew<CR>", { desc = "New Tab" })
map("n", "<leader>w", ":w ++p ++bad=drop<CR>", { desc = "Save" })
map("n", "<leader>q", ":q<CR>", { desc = "Quit" })
map("n", "<leader><", "V`[<", { desc = "indent the pasted words" })
map("n", "<leader>>", "V`]>", { desc = "redo indent the pasted words" })
map( ---------------
  "n",
  "<leader>ca",
  "<cmd>s/\\<\\(\\w\\)\\(\\S*\\)/\\u\\1\\L\\2/g<CR><cmd>noh<CR>",
  { desc = "Set The First Letter of Each Word Capital" }
) ---------------
map("n", "<C-c>", "<ESC>", { desc = "Map Ctrl + C to True Esc" })
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
map("n", "<C-P>", "<cmd>put<CR>", { desc = "Paste Below" })

map("n", "<leader><leader>", function()
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
map("n", "<leader>i", function() -----------------
  vim.cmd "startinsert"
  nio.run(function()
    -- print "切換為嘸蝦米輸入法！"
    local line_num = vim.api.nvim_win_get_cursor(0)[1] - 1
    vim.api.nvim_buf_set_extmark(0, vim.api.nvim_create_namespace "virtual_text", line_num, -1, {
      virt_text = { { " 嘸蝦米", "Comment" } },
      virt_text_pos = "eol",
    })
    os.execute "im-select com.boshiamy.inputmethod.BoshiamyIMK"
  end)
end, { desc = "when go into the insert mode, switch to boshiamy.inputmethod" })

-- insert mode --
map("i", "<C-c>", "<ESC>", { desc = "Escape" })

-- visual mode --
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })
map("v", ";", ":", { desc = "enter command mode" })
map("v", "<leader>ga", ":'<,'>!aicomp<cr>", { desc = "Aider Append" })
map("v", "p", '"_dP', { desc = "paste but don't overwrite the clipboard" })
map("v", "ij", "i[", { desc = "same as i[" })
map("v", "ik", "i{", { desc = "same as i{" })
map("v", "ih", "i<", { desc = "same as i<" })
map("v", "im", "i'", { desc = "same as i'" })
map("v", "i,", 'i"', { desc = 'same as i"' })
map("v", "aj", "a[", { desc = "same as a[" })
map("v", "ak", "a{", { desc = "same as a{" })
map("v", "ah", "a<", { desc = "same as a<" })
map("v", "am", "a'", { desc = "same as a'" })
map("v", "a,", 'a"', { desc = 'same as a"' })
map("v", "L", "$h", { desc = "go to end of line" })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "move the selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "move the selection up" })
map("v", "H", "^", { desc = "begining of line" })
