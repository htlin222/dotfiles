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
-- require("func.anki").add_to_anki()
-- Create the Vim command
return M
