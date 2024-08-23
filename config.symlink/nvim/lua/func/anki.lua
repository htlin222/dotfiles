local nio = require "nio"
local M = {}
local vim = vim

function M.add_to_anki(deck)
  nio.run(function()
    local current_buffer_path = vim.api.nvim_buf_get_name(0)
    if current_buffer_path ~= nil and current_buffer_path ~= "" then
      local home = os.getenv "HOME"
      deck = deck or "00_Inbox"
      local cmd = string.format('%s/bin/md_to_anki/md_to_anki -f "%s" --deck "%s"', home, current_buffer_path, deck)
      local handle = io.popen(cmd)
      local result = handle:read "*a"
      handle:close()
      vim.api.nvim_echo({ { result, "Normal" } }, false, {})
      vim.defer_fn(function()
        vim.api.nvim_echo({ { "", "Normal" } }, false, {})
      end, 3000) -- 保持3秒
    else
      print "當前緩衝區的路徑為空或無效"
    end
  end)
end

function M.splitbyh2()
  -- 檢查當前緩衝區是否為 .md 文件
  if vim.fn.expand "%:e" == "md" then
    local filepath = vim.fn.expand "%:p"
    local command = 'python ~/pyscripts/split_by_h2.py "' .. filepath .. '"'
    os.execute(command)
    vim.cmd "echohl Blue"
    vim.cmd 'echom "🤞領域展開✨領域展開🤞"'
    vim.cmd 'echom "✨ むりょうくうきょ ✨"'
    vim.cmd "echohl None"
    vim.cmd "edit"
  else
    print "Current buffer is not a Markdown file."
  end
end

local function split_md_content(content)
  -- 找到第一個一級標題的位置
  local first_heading_index = content:find "# "
  if not first_heading_index then
    print "未找到一級標題 '# '"
    return nil, nil
  end

  -- 找到第一個一級標題的結尾（換行符號之後）
  local first_heading_end = content:find("\n", first_heading_index)

  -- 提取 front（第一個一級標題的文字內容）
  local front = vim.trim(content:sub(first_heading_index + 2, first_heading_end - 1))

  -- 提取 back（去掉第一個一級標題後的所有內容）
  local back = vim.trim(content:sub(first_heading_end + 1))

  -- 將 back 中的所有二級標題替換為三級標題
  back = back:gsub("## ", "### ")

  return front, back
end

local function create_note_template(front, back)
  local template = string.format(
    [[
model: Basic
deck: 00_Inbox
tags:

# Note

## Front

%s

## Back

%s
]],
    front,
    back
  )
  return template
end

local function save_note_template(template, original_filename)
  -- 建立目錄（如果不存在）
  local directory = "/tmp/anki_note"
  vim.fn.mkdir(directory, "p")

  -- 取得當前時間
  local current_time = os.date "%Y%m%d%H%M%S"
  -- 取得檔案名（不包含副檔名）
  local filename_without_extension = vim.fn.fnamemodify(original_filename, ":t:r")
  -- 組合新的檔案名
  local new_filename = directory .. "/" .. filename_without_extension .. "_" .. current_time .. ".md"

  -- 寫入檔案
  local file = io.open(new_filename, "w")
  file:write(template)
  file:close()

  print("筆記已儲存至 " .. new_filename)
end

function M.convert_to_note()
  local buffer_content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  local file_path = vim.api.nvim_buf_get_name(0)

  local front, back = split_md_content(buffer_content)
  if front and back then
    local template = create_note_template(front, back)
    save_note_template(template, file_path)
  end
end

return M

-- you should require("func.anki").fu()
