-- 插件相關按鍵映射
local function map(modes, lhs, rhs, opts)
  opts.silent = opts.silent ~= false
  opts.nowait = opts.nowait ~= false
  vim.keymap.set(modes, lhs, rhs, opts)
end

return function()
  -- Lspsaga 插件按鍵映射
  map("n", "<leader>lo", "<cmd>Lspsaga outline<CR>", { desc = "Lspsaga Code Outline" })
  map("n", "K", "<cmd>Lspsaga hover_doc<CR>", { desc = "Hover Doc" })
  map("n", "<leader>fd", "<cmd>ArenaToggle<CR>", { desc = "ArenaToggle", nowait = true, silent = false })
  
  -- Diagnostic 診斷按鍵映射
  map("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
  map("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
  map("n", "[e", function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end, { desc = "Go to previous error" })
  map("n", "]e", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end, { desc = "Go to next error" })
  map("n", "<leader>de", vim.diagnostic.open_float, { desc = "Show diagnostic in float window" })
  map("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Add diagnostics to location list" })
  map("n", "<leader>dt", function() require("tiny-inline-diagnostic").toggle() end, { desc = "Toggle inline diagnostics" })
  
  -- FeMaco 代碼區塊編輯按鍵映射
  map("n", "<leader>ce", function() require("femaco.edit").edit_code_block() end, { desc = "Edit code block in floating window" })
  map("n", "<leader>cc", function() require("femaco.edit").edit_code_block() end, { desc = "Edit code block (alias)" })
  
  -- Telescope Project 按鍵映射
  map("n", "<leader>fp", "<cmd>Telescope project<CR>", { desc = "Find Projects" })
  map("n", "<leader>pp", "<cmd>Telescope project<CR>", { desc = "Switch Project" })
  
  -- Telescope Extensions 按鍵映射
  map("n", "<leader>fu", "<cmd>Telescope undo<CR>", { desc = "Undo History" })
  map("n", "<leader>fb", "<cmd>Telescope file_browser<CR>", { desc = "File Browser" })
  map("n", "<leader>fm", "<cmd>Telescope media_files<CR>", { desc = "Media Files" })
  map("n", "<leader>fC", "<cmd>Telescope neoclip<CR>", { desc = "Clipboard History" })
  map("n", "<leader>fs", "<cmd>Telescope symbols<CR>", { desc = "Symbols" })
  map("n", "<leader>fz", "<cmd>Telescope zotero<CR>", { desc = "Zotero" })
  
  -- GitHub Telescope 按鍵映射
  map("n", "<leader>ghi", "<cmd>Telescope gh issues<CR>", { desc = "GitHub Issues" })
  map("n", "<leader>ghp", "<cmd>Telescope gh pull_request<CR>", { desc = "GitHub Pull Requests" })
  map("n", "<leader>ghr", "<cmd>Telescope gh run<CR>", { desc = "GitHub Actions" })
  
  -- DAP Telescope 按鍵映射
  map("n", "<leader>db", "<cmd>Telescope dap list_breakpoints<CR>", { desc = "DAP Breakpoints" })
  map("n", "<leader>dv", "<cmd>Telescope dap variables<CR>", { desc = "DAP Variables" })
  map("n", "<leader>df", "<cmd>Telescope dap frames<CR>", { desc = "DAP Frames" })
end