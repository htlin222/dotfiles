-- Test template loading
print("=== Testing template creation ===")

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Test creating the augroup and autocmd
print("Creating Python augroup...")
local python_group = augroup("Python", { clear = true })
print("Python group ID:", python_group)

print("Creating Python autocmd...")
autocmd("BufNewFile", {
  group = python_group,
  pattern = "*.py",
  callback = function()
    print("Python template triggered!")
    local lines = {
      "#!/usr/bin/env python3",
      "# -*- coding: utf-8 -*-",
      "# Test template",
      "",
      "def main():",
      '    print("Hello, World!")',
      "",
      'if __name__ == "__main__":',
      "    main()",
    }
    vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
  end,
})

print("Autocmd created successfully!")

-- Check if it's registered
local autocmds = vim.api.nvim_get_autocmds({
  group = python_group,
  event = "BufNewFile",
  pattern = "*.py"
})

print("Registered autocmds:", #autocmds)