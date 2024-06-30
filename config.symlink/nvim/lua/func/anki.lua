local nio = require "nio"
local M = {}
local vim = vim

function M.add_to_anki()
  nio.run(function()
    local current_buffer_path = vim.api.nvim_buf_get_name(0)
    if current_buffer_path ~= nil and current_buffer_path ~= "" then
      local home = os.getenv "HOME"
      local cmd = string.format('%s/bin/md_to_anki/md_to_anki -f "%s"', home, current_buffer_path)
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
-- require("func.anki").add_to_anki()
return M
