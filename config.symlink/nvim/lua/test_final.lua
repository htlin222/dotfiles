-- Final test to see what's happening
print("=== Final debug test ===")

-- Check if the module loads
local success, result = pcall(require, "autocmd")
print("require autocmd success:", success)
if not success then
  print("Error:", result)
end

-- Check if fttemplate is loaded
local success2, result2 = pcall(require, "autocmd.fttemplate")  
print("require autocmd.fttemplate success:", success2)
if not success2 then
  print("Error:", result2)
end

-- Check for Python group
local groups = vim.api.nvim_get_autocmds({})
local python_found = false
for _, cmd in ipairs(groups) do
  if cmd.group == "Python" then
    python_found = true
    print("Found Python autocmd:", cmd.event, cmd.pattern)
  end
end

if not python_found then
  print("Python autocmd not found")
end

-- Test file creation
local temp_file = "/tmp/debug_test.py"
os.execute("rm -f " .. temp_file)
vim.cmd("edit " .. temp_file)
local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
print("File has", #lines, "lines after creation")
if #lines > 1 then
  print("Template working!")
else
  print("Template not working")
end
os.execute("rm -f " .. temp_file)