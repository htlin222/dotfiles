local vim = vim
-- 定義自動命令組
-- 定義一個函數來檢查並提示用戶
local function check_and_prompt_publish()
  -- 獲取當前緩衝區的內容
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  -- 檢查是否包含 "draft: false"
  local is_draft = false
  for _, line in ipairs(lines) do
    if line:match "draft: true" then
      is_draft = true
      break
    end
  end

  -- 如果包含，提示用戶
  if is_draft then
    local response = vim.fn.input "Are You Going to publish this y/n: "
    if response == "y" then
      -- 修改 "draft: false" 為 "draft: true"
      for i, line in ipairs(lines) do
        if line:match "draft: true" then
          lines[i] = line:gsub("draft: true", "draft: false")
          break
        end
      end
      -- 將修改後的內容設置回緩衝區
      vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    end
  end
end
local group_id = vim.api.nvim_create_augroup("draft", { clear = true })

-- 設置 BufWritePre 自動命令來觸發上面的函數
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.md",
  callback = check_and_prompt_publish,
  group = group_id,
})

vim.api.nvim_create_augroup("creatprevious", {})

-- 添加自動命令到組
vim.api.nvim_create_autocmd("BufLeave", {
  pattern = "*.md",
  callback = function()
    vim.g.previous = vim.fn.expand "%:t:r"
  end,
  group = "creatprevious",
})

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  callback = function()
    local line_count = vim.api.nvim_buf_line_count(0)
    local target_line = math.min(10, line_count)
    vim.api.nvim_win_set_cursor(0, { target_line, 0 })
  end,
})
vim.api.nvim_create_autocmd("BufNewFile", {
  group = vim.api.nvim_create_augroup("CreateMedicalDiaryGroup", {}),
  callback = function()
    vim.b._should_add_header = true
  end,
})

vim.api.nvim_create_autocmd("BufNewFile", {
  group = vim.api.nvim_create_augroup("CreateMedicalDiaryGroup", {}),
  callback = function()
    vim.b._should_add_header = true
    print("🪄 BufNewFile triggered:", vim.fn.expand "%")
  end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("InsertHeaderIfNeeded", {}),
  callback = function()
    if not vim.b._should_add_header then
      return
    end
    vim.b._should_add_header = false

    print("🚪 BufWinEnter:", vim.fn.expand "%")
    print("📁 CWD:", vim.fn.getcwd())
    print("📄 Extension:", vim.fn.expand "%:e")
    print("📌 Full path:", vim.api.nvim_buf_get_name(0))
  end,
})

-- 建立專屬 group，避免被覆蓋
local group = vim.api.nvim_create_augroup("MyAutoHeaderDebug", { clear = true })

-- 監聽 BufNewFile（新檔案建立時）
vim.api.nvim_create_autocmd("BufNewFile", {
  group = group,
  pattern = "*.md", -- 只針對 .md 檔案
  callback = function()
    vim.b._should_add_header = true
    print("🆕 BufNewFile: " .. vim.fn.expand "%")
  end,
})

-- 監聽 BufEnter（切進 buffer）
vim.api.nvim_create_autocmd("BufEnter", {
  group = group,
  pattern = "*.md",
  callback = function()
    if not vim.b._should_add_header then
      return
    end
    vim.b._should_add_header = false

    print("🚪 BufEnter: " .. vim.fn.expand "%")
    print("📄 Full path: " .. vim.api.nvim_buf_get_name(0))
  end,
})
