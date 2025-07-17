-- Test with real file creation
print("=== Testing real file creation ===")

-- Load fttemplate first
require("autocmd.fttemplate")

-- Create a temporary file
local temp_file = "/tmp/test_python_template.py"
os.execute("rm -f " .. temp_file)

-- Open the file in nvim
vim.cmd("edit " .. temp_file)

-- Check buffer contents
local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
print("Buffer has", #lines, "lines")
for i, line in ipairs(lines) do
  print("Line", i, ":", line)
end

-- Clean up
os.execute("rm -f " .. temp_file)