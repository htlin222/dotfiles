-- Manual plugin for custom help system
-- Creates a :Manual command to open help documentation

return {
  "manual-help-system",
  dir = vim.fn.stdpath("config"),
  lazy = false,
  config = function()
    -- Get the path to the docs directory
    local docs_path = vim.fn.stdpath("config") .. "/docs"
    
    -- Create the Manual command
    vim.api.nvim_create_user_command("Manual", function(opts)
      -- If a topic is provided, try to jump to it
      local topic = opts.args and opts.args ~= "" and opts.args or nil
      
      -- Open the manual file in a split
      vim.cmd("rightbelow split")
      vim.cmd("edit " .. docs_path .. "/manual.txt")
      
      -- Set up the buffer as a help buffer
      vim.bo.buftype = "help"
      vim.bo.filetype = "help"
      vim.bo.readonly = true
      vim.bo.modifiable = false
      
      -- If a topic was provided, jump to it
      if topic then
        -- Try to find the topic tag
        local tag_pattern = "*" .. topic .. "*"
        vim.fn.search(tag_pattern, "w")
      end
      
      -- Set up some help buffer specific settings
      vim.wo.number = false
      vim.wo.relativenumber = false
      vim.wo.signcolumn = "no"
      vim.wo.foldcolumn = "0"
      
      -- Map q to close the manual
      vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = true, silent = true })
      
      -- Map <C-]> to jump to tags (like in normal help)
      vim.keymap.set("n", "<C-]>", function()
        local word = vim.fn.expand("<cWORD>")
        -- Remove surrounding | characters if present
        word = word:gsub("^|", ""):gsub("|$", "")
        -- Try to find the tag
        local tag_pattern = "*" .. word .. "*"
        if vim.fn.search(tag_pattern, "w") == 0 then
          vim.notify("Tag not found: " .. word, vim.log.levels.WARN)
        end
      end, { buffer = true, silent = true })
      
      -- Map <C-o> to go back (basic navigation)
      vim.keymap.set("n", "<C-o>", "<C-o>", { buffer = true, silent = true })
    end, {
      desc = "Open configuration manual",
      nargs = "?",
      complete = function()
        -- Basic completion for common topics
        return {
          "commands",
          "architecture", 
          "keybindings",
          "plugins",
          "lsp",
          "snippets",
          "datascience",
          "academic",
          "development"
        }
      end
    })
    
    -- Optional: Create a keymap to quickly open the manual
    vim.keymap.set("n", "<leader>hm", "<cmd>Manual<cr>", { 
      desc = "Open configuration manual",
      silent = true 
    })
    
    -- Add to help tags (if helptags is available)
    local help_dir = docs_path
    if vim.fn.isdirectory(help_dir) == 1 then
      pcall(vim.cmd, "helptags " .. help_dir)
    end
  end,
}