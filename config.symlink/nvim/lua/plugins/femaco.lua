return {
  "AckslD/nvim-FeMaco.lua",
  ft = { "markdown" },
  config = function()
    require("femaco").setup({
      -- Floating window configuration
      float_opts = function(code_block)
        local width = math.floor(vim.o.columns * 0.8)
        local max_height = math.floor(vim.o.lines * 0.67) -- 2/3 of main window height
        
        -- Get the number of lines in the code block
        local code_lines = #code_block.lines
        -- Add some padding for better editing experience
        local desired_height = math.min(code_lines + 5, max_height)
        
        -- Center the window
        local row = math.floor((vim.o.lines - desired_height) / 2)
        local col = math.floor((vim.o.columns - width) / 2)
        
        return {
          relative = "editor",
          width = width,
          height = desired_height,
          row = row,
          col = col,
          style = "minimal",
          border = "rounded",
        }
      end,
      -- Language mapping
      ft_from_lang = function(lang)
        local lang_map = {
          js = "javascript",
          ts = "typescript",
          jsx = "javascriptreact",
          tsx = "typescriptreact",
          py = "python",
          rb = "ruby",
          sh = "bash",
          yml = "yaml",
          json = "json",
          html = "html",
          css = "css",
          sql = "sql",
          r = "r",
          R = "r",
          julia = "julia",
          go = "go",
          rust = "rust",
          java = "java",
          cpp = "cpp",
          c = "c",
          php = "php",
          lua = "lua",
          vim = "vim",
          dockerfile = "dockerfile",
          tex = "tex",
          latex = "tex",
          md = "markdown",
        }
        return lang_map[lang] or lang
      end,
      -- Post-open configuration
      post_open_float = function(winnr, bufnr, code_block)
        vim.api.nvim_set_option_value("winhl", "Normal:Normal", { win = winnr })
        vim.api.nvim_set_option_value("expandtab", true, { buf = bufnr })
        vim.api.nvim_set_option_value("shiftwidth", 2, { buf = bufnr })
        vim.api.nvim_set_option_value("tabstop", 2, { buf = bufnr })
      end,
      -- Create undo point when editing
      create_undo_point = true,
    })
  end,
}