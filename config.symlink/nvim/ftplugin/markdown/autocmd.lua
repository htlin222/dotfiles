local vim = vim
-- 定義自動命令組
-- 定義一個函數來檢查並提示用戶
local function check_and_prompt_publish()
  -- 獲取當前緩衝區的內容
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  -- 檢查是否包含 "draft: false"
  local contains_draft_false = false
  for _, line in ipairs(lines) do
    if line:match "draft: false" then
      contains_draft_false = true
      break
    end
  end

  -- 如果包含，提示用戶
  if contains_draft_false then
    local response = vim.fn.input "Are You Going to publish this y/n: "
    if response == "y" then
      -- 修改 "draft: false" 為 "draft: true"
      for i, line in ipairs(lines) do
        if line:match "draft: false" then
          lines[i] = line:gsub("draft: false", "draft: true")
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
