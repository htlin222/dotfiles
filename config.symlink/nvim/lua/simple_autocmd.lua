-- Simple autocmd test
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.py",
  callback = function()
    local lines = {
      "#!/usr/bin/env python3",
      "# Simple template test",
      "",
      "def main():",
      '    print("Hello from simple template!")',
      "",
      'if __name__ == "__main__":',
      "    main()",
    }
    vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
  end,
})