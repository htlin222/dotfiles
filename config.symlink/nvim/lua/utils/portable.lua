local M = {}

local uv = vim.uv or vim.loop

function M.os()
  if uv and uv.os_uname then
    local ok, uname = pcall(uv.os_uname)
    if ok and uname and uname.sysname then
      return uname.sysname
    end
  end
  if vim.fn.has("mac") == 1 then
    return "Darwin"
  end
  if vim.fn.has("linux") == 1 then
    return "Linux"
  end
  if vim.fn.has("win32") == 1 then
    return "Windows"
  end
  return ""
end

function M.path_exists(path)
  if not path or path == "" then
    return false
  end
  if uv and uv.fs_stat then
    return uv.fs_stat(path) ~= nil
  end
  return vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1
end

function M.is_dir(path)
  if not path or path == "" then
    return false
  end
  if uv and uv.fs_stat then
    local stat = uv.fs_stat(path)
    return stat and stat.type == "directory"
  end
  return vim.fn.isdirectory(path) == 1
end

function M.is_executable(cmd)
  return vim.fn.executable(cmd) == 1
end

function M.find_python()
  if M.is_executable("python3") then
    return "python3"
  end
  if M.is_executable("python") then
    return "python"
  end
  return nil
end

function M.safe_require(name)
  local ok, mod = pcall(require, name)
  if ok then
    return mod
  end
  return nil
end

return M
