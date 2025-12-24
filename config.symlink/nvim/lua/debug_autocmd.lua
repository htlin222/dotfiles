-- Debug script to check autocmd registration
print("=== Debugging autocmd registration ===")

-- Check OS detection
local uname = vim.uv.os_uname()
print("OS detected:", uname.sysname)

-- Check if autocmd is registered
local success, autocmds = pcall(vim.api.nvim_get_autocmds, {
  group = "Python",
  event = "BufNewFile",  
  pattern = "*.py"
})

if success then
  print("Python autocmds found:", #autocmds)
  for i, cmd in ipairs(autocmds) do
    print("  Autocmd", i, ":", cmd.group, cmd.event, cmd.pattern)
  end
else
  print("Python group not found, checking all groups...")
  -- List all augroups
  local groups = vim.api.nvim_get_autocmds({})
  local python_found = false
  for i, cmd in ipairs(groups) do
    if cmd.group and string.match(cmd.group, "Python") then
      python_found = true
      print("  Found Python group:", cmd.group)
    end
  end
  if not python_found then
    print("  No Python-related groups found")
  end
end

-- List all BufNewFile autocmds
local all_bufnewfile = vim.api.nvim_get_autocmds({
  event = "BufNewFile"
})

print("\nAll BufNewFile autocmds:")
for i, cmd in ipairs(all_bufnewfile) do
  if cmd.pattern and string.match(cmd.pattern, "%.py") then
    print("  Python related:", cmd.group, cmd.pattern)
  end
end