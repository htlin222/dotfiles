local vim = vim
local function map(modes, lhs, rhs, opts)
  -- opts.unique = opts.unique ~= false
  opts.silent = opts.silent ~= false
  opts.nowait = opts.nowait ~= false
  vim.keymap.set(modes, lhs, rhs, opts)
end
-- normal mode --

-- 👉 [[wiwki link]]
map("n", "<leader>yw", function()
  local file_name = vim.fn.expand "%:t:r"
  local formatted_file_name = "[[" .. file_name .. "]]"
  vim.fn.setreg("+", formatted_file_name, "y")
  print(formatted_file_name)
end, { desc = "Yank Filename as wikilink" })
-- add to anki
map("n", "<leader>an", function()
  require("func.anki").add_to_anki()
end, { desc = "Add this note to anki" })
-- 👉 [[paste as wiki link]]
map("n", "<leader>pw", function()
  local content = vim.fn.getreg '"'
  local content = content:gsub("%c", "")
  local bracketedContent = "[[" .. content .. "]]"
  vim.api.nvim_put({ bracketedContent }, "c", false, true)
end, { desc = "PasteWithBracketed" })
-- paste "of this file"
map("n", "<leader>of", function()
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()
  local line = vim.api.nvim_win_get_cursor(win)[1]
  local line_length = string.len(vim.api.nvim_buf_get_lines(buf, line - 1, line, false)[1])
  vim.api.nvim_win_set_cursor(win, { line, line_length })
  local file_name = vim.fn.expand "%:t:r"
  local formatted_file_name = "-of-" .. file_name
  local clipboard_content = vim.fn.getreg "+" -- 獲取剪貼板原本內容
  vim.api.nvim_put({ formatted_file_name }, "c", true, true)
  vim.fn.setreg("+", clipboard_content) -- 恢復剪貼板內容
  print(formatted_file_name)
end, { desc = "create text: of this file", silent = false })
map("n", "<leader>aa", function()
  local current_line = vim.api.nvim_get_current_line()
  local new_line = "## " .. current_line
  vim.api.nvim_set_current_line(new_line)
end, { desc = "add level 2", silent = false, nowait = true })
map("n", "<leader><CR>", function()
  local lines = { "", "", "---", "", "" }
  local current_line = vim.fn.line "."
  vim.api.nvim_buf_set_lines(0, current_line, current_line, false, lines)
  vim.api.nvim_win_set_cursor(0, { current_line + #lines, 0 })
  vim.cmd "echomsg '新增一頁投影片'"
end, { desc = "Follow Link", silent = false, nowait = true })
map("n", "<leader>mz", function()
  vim.cmd "write"
  local file_name = vim.fn.expand "%:p"
  local snippets_path = "~/.dotfiles/neovim/vscode_snippets/garden.json"
  local cmd = string.format("python ~/pyscripts/add_snippets.py '%s' '%s'", file_name, snippets_path)
  vim.fn.system(cmd)
  vim.cmd "echohl Identifier"
  vim.cmd "echomsg '加入片語'"
  vim.cmd "echohl None"
end, { desc = "Add snippets filename", silent = false, nowait = true })

map(
  "n",
  "<leader>s.",
  ":silent! call SubstitutionForCurrentLine()<CR>",
  { desc = "split line", silent = false, nowait = true }
)

map(
  "n",
  "<leader>s.",
  ":silent! call SubstitutionForCurrentLine()<CR>",
  { desc = "split line", silent = false, nowait = true }
)
map(
  "n",
  "<leader>s,",
  ":silent! call SubstitutionForCurrentLineComma()<CR>",
  { desc = "split line by comma", silent = true, nowait = true }
)
map(
  "n",
  "<leader>sc",
  ":silent! call SubstitutionForCurrentChineseComma()<CR>",
  { desc = "split line by chinese comma", silent = false, nowait = true }
)
map(
  "n",
  "<leader>;",
  ":silent! call SubstitutionForCurrentLineSemiColon()<CR>",
  { desc = "split line by semicolon", silent = false, nowait = true }
)
map(
  "n",
  "<leader>mr",
  ":call Recruit()<CR>",
  { desc = "Recruit wikilink if start with [[", silent = false, nowait = true }
)

map("n", "<leader>s2", ":call SplitByH2()<CR>", { desc = "Split by H2 with wikilink", silent = false, nowait = true })
map("n", "<leader>mt", ":TableModeToggle<CR>", { desc = "TableModeToggle", silent = false, nowait = true })
