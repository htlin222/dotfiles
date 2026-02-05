-- 插件相關按鍵映射
local function map(modes, lhs, rhs, opts)
  opts.silent = opts.silent ~= false
  opts.nowait = opts.nowait ~= false
  vim.keymap.set(modes, lhs, rhs, opts)
end

return function()
  local function toggle_inlay_hints()
    if not vim.lsp or not vim.lsp.inlay_hint then
      vim.notify("Inlay hints not supported in this Neovim version", vim.log.levels.WARN)
      return
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local enabled = false

    if vim.lsp.inlay_hint.is_enabled then
      local ok, val = pcall(vim.lsp.inlay_hint.is_enabled, { bufnr = bufnr })
      if not ok then
        ok, val = pcall(vim.lsp.inlay_hint.is_enabled, bufnr)
      end
      if ok then
        enabled = val
      end
    else
      enabled = vim.b.inlay_hint_enabled or false
    end

    local new_state = not enabled
    local ok = pcall(vim.lsp.inlay_hint.enable, new_state, { bufnr = bufnr })
    if not ok then
      pcall(vim.lsp.inlay_hint.enable, { bufnr = bufnr }, new_state)
    end

    vim.b.inlay_hint_enabled = new_state
    vim.notify(("Inlay hints %s"):format(new_state and "enabled" or "disabled"), vim.log.levels.INFO)
  end

  local function toggle_focus_mode()
    local ok_lazy, lazy = pcall(require, "lazy")
    if ok_lazy then
      lazy.load({ plugins = { "zen-mode.nvim", "twilight.nvim" } })
    end

    vim.g.focus_mode_enabled = not vim.g.focus_mode_enabled
    local enable = vim.g.focus_mode_enabled

    local ok_zen, zen = pcall(require, "zen-mode")
    if ok_zen then
      if enable and zen.open then
        zen.open()
      elseif (not enable) and zen.close then
        zen.close()
      elseif zen.toggle then
        zen.toggle()
      else
        pcall(vim.cmd, "ZenMode")
      end
    else
      pcall(vim.cmd, "ZenMode")
    end

    local ok_tw, tw = pcall(require, "twilight")
    if ok_tw then
      if enable and tw.enable then
        tw.enable()
      elseif (not enable) and tw.disable then
        tw.disable()
      elseif tw.toggle then
        tw.toggle()
      else
        pcall(vim.cmd, "Twilight")
      end
    else
      pcall(vim.cmd, "Twilight")
    end
  end

  -- Lspsaga 插件按鍵映射
  map("n", "<leader>lo", "<cmd>Lspsaga outline<CR>", { desc = "Lspsaga Code Outline" })
  map("n", "K", "<cmd>Lspsaga hover_doc<CR>", { desc = "Hover Doc" })
  map("n", "<leader>fd", "<cmd>ArenaToggle<CR>", { desc = "ArenaToggle", nowait = true, silent = false })
  
  -- Diagnostic 診斷按鍵映射
  map("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
  map("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
  map("n", "[e", function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end, { desc = "Go to previous error" })
  map("n", "]e", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end, { desc = "Go to next error" })
  map("n", "<leader>de", vim.diagnostic.open_float, { desc = "Show diagnostic in float window" })
  map("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Add diagnostics to location list" })
  map("n", "<leader>dt", function() require("tiny-inline-diagnostic").toggle() end, { desc = "Toggle inline diagnostics" })
  map("n", "<leader>ti", toggle_inlay_hints, { desc = "Toggle LSP inlay hints" })
  map("n", "<leader>zf", toggle_focus_mode, { desc = "Focus mode (Zen + Twilight)" })
  
  -- FeMaco 代碼區塊編輯按鍵映射
  map("n", "<leader>ce", function() require("femaco.edit").edit_code_block() end, { desc = "Edit code block in floating window" })
  map("n", "<leader>cc", function() require("femaco.edit").edit_code_block() end, { desc = "Edit code block (alias)" })
  
  -- Telescope Project 按鍵映射
  map("n", "<leader>fp", "<cmd>Telescope project<CR>", { desc = "Find Projects" })
  map("n", "<leader>pp", "<cmd>Telescope project<CR>", { desc = "Switch Project" })
  
  -- Telescope Extensions 按鍵映射
  map("n", "<leader>fu", "<cmd>Telescope undo<CR>", { desc = "Undo History" })
  map("n", "<leader>fb", "<cmd>Telescope file_browser<CR>", { desc = "File Browser" })
  map("n", "<leader>fm", "<cmd>Telescope media_files<CR>", { desc = "Media Files" })
  map("n", "<leader>fC", "<cmd>Telescope neoclip<CR>", { desc = "Clipboard History" })
  map("n", "<leader>fs", "<cmd>Telescope symbols<CR>", { desc = "Symbols" })
  map("n", "<leader>fz", "<cmd>Telescope zotero<CR>", { desc = "Zotero" })
  
  -- GitHub Telescope 按鍵映射
  map("n", "<leader>ghi", "<cmd>Telescope gh issues<CR>", { desc = "GitHub Issues" })
  map("n", "<leader>ghp", "<cmd>Telescope gh pull_request<CR>", { desc = "GitHub Pull Requests" })
  map("n", "<leader>ghr", "<cmd>Telescope gh run<CR>", { desc = "GitHub Actions" })
  
  -- DAP Telescope 按鍵映射
  map("n", "<leader>db", "<cmd>Telescope dap list_breakpoints<CR>", { desc = "DAP Breakpoints" })
  map("n", "<leader>dv", "<cmd>Telescope dap variables<CR>", { desc = "DAP Variables" })
  map("n", "<leader>df", "<cmd>Telescope dap frames<CR>", { desc = "DAP Frames" })
end
