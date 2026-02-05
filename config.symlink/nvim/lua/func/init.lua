local vim = vim
local M = {}

function M.append_current_line()
  if vim.o.encoding == "" then
    vim.o.encoding = "utf-8"
  end
  local current_line = vim.fn.getline "."
  -- local trimmed_line = string.sub(current_line, 3)
  local trimmed_line = current_line
  local current_file = vim.fn.expand "%:t"
  local combined_text = "In " .. current_file .. ": " .. trimmed_line
  local append_cmd = ":silent GpAppend " .. combined_text
  vim.cmd(append_cmd)
  print "已產生結果了"
  vim.cmd ":normal!<CR>"
end

function M.append_visual_selection()
  -- 检查是否在 Visual 模式下
  if vim.fn.visualmode() ~= "V" then
    vim.api.nvim_err_writeln "Not in Visual mode"
    return
  end
  local selection = vim.fn.getreg ""
  local append_cmd = ":GpAppend " .. selection
  vim.cmd(append_cmd)
end

function M.reload_config()
  for name, _ in pairs(package.loaded) do
    if name:match "^user" and not name:match "nvim-tree" then
      package.loaded[name] = nil
    end
  end

  dofile(vim.env.MYVIMRC)
  vim.notify("Nvim configuration reloaded!", vim.log.levels.INFO)
end

function M.copy_outline_to_clipboard()
  local current_buffer_file = vim.api.nvim_buf_get_name(0) -- 獲取當前緩衝檔案的名稱
  -- 跨平台剪貼板命令
  local copy_cmd
  if vim.fn.has("mac") == 1 then
    copy_cmd = "pbcopy"
  elseif vim.env.WAYLAND_DISPLAY and vim.fn.executable("wl-copy") == 1 then
    copy_cmd = "wl-copy"
  elseif vim.fn.executable("xclip") == 1 then
    copy_cmd = "xclip -selection clipboard"
  elseif vim.fn.executable("xsel") == 1 then
    copy_cmd = "xsel --clipboard --input"
  else
    vim.notify("No clipboard tool found!", vim.log.levels.ERROR)
    return
  end
  local command = 'sed -n \'/<!-- _header: "Outline" -->/,/<!-- _footer: "" -->/{/<!-- _header: "Outline" -->/!{/<!-- _footer: "" -->/!p;};}\' '
    .. current_buffer_file
    .. " | " .. copy_cmd
  os.execute(command) -- 執行命令
  print "臭蜥蜴"
end

-- 定義打開當前檔案的函數
function M.open_with_default_app()
  local current_file = vim.fn.expand "%:p" -- 獲取當前緩衝區的檔案路徑
  local user_input = vim.fn.input("要打開📂" .. vim.fn.expand "%" .. "嗎? [Y]是 [N]否): ")
  if user_input == "y" then
    -- 跨平台打開命令
    local open_cmd
    if vim.fn.has("mac") == 1 then
      open_cmd = "open"
    elseif vim.fn.has("unix") == 1 then
      open_cmd = "xdg-open"
    elseif vim.fn.has("win32") == 1 then
      open_cmd = "start"
    end
    local open_command = open_cmd .. " " .. vim.fn.shellescape(current_file)
    vim.fn.system(open_command)
    print "開🔥"
  else
    print "你底心是小小的窗扉緊掩"
  end
end

function M.remove_under_score_and_capitalize()
  -- 獲取當前行內容
  local line = vim.api.nvim_get_current_line()

  -- 移除底線並在每個詞之間加入空格
  line = line:gsub("_", " ")

  -- 將每個詞的首字母大寫
  line = line:gsub("(%a)(%w*)", function(first, rest)
    return string.upper(first) .. rest
  end)

  -- 設置當前行內容
  vim.api.nvim_set_current_line(line)
end

function M.yank_with_context()
  -- Get visual selection range
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  
  -- Get file path and filetype
  local file_path = vim.fn.expand("%:p")
  local filetype = vim.bo.filetype
  
  -- Get selected lines
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local content = table.concat(lines, "\n")
  
  -- Format the yanked text with code block
  local formatted
  if start_line == end_line then
    formatted = string.format("@%s line %d:\n```%s\n%s\n```", file_path, start_line, filetype, content)
  else
    formatted = string.format("@%s line %d to %d:\n```%s\n%s\n```", file_path, start_line, end_line, filetype, content)
  end
  
  -- Yank to clipboard
  vim.fn.setreg("+", formatted)
  vim.fn.setreg('"', formatted)
  
  -- Notify user
  vim.notify(string.format("Yanked %d line(s) with context", end_line - start_line + 1), vim.log.levels.INFO)
end

return M
