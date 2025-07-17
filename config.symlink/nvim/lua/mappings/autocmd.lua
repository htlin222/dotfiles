-- 自動命令相關的按鍵映射
return function()
  -- Markdown 文件中的代碼區塊 Enter 鍵映射
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
      -- Wait for other plugins to set their mappings first
      vim.defer_fn(function()
        vim.keymap.set("n", "<CR>", function()
          -- Check if cursor is in a code block
          local cursor_pos = vim.api.nvim_win_get_cursor(0)
          local row = cursor_pos[1]
          local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
          
          -- Find if we're inside a code block
          local in_code_block = false
          local code_block_count = 0
          
          for i = 1, row do
            local current_line = lines[i]
            if current_line and current_line:match("^```") then
              code_block_count = code_block_count + 1
            end
          end
          
          -- If odd number of ``` above current line, we're in a code block
          in_code_block = code_block_count % 2 == 1
          
          if in_code_block then
            -- We're in a code block, use FeMaco to edit
            require("femaco.edit").edit_code_block()
          else
            -- Not in a code block, use mkdnflow's behavior directly
            require('mkdnflow').links.followLink()
          end
        end, { buffer = true, desc = "Edit code block or original <CR> behavior" })
      end, 100) -- Delay to ensure other plugins have set their mappings
    end,
  })
end