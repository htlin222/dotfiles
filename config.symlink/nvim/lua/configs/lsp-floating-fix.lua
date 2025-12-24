-- Robust LSP Floating Window Fix
-- This module provides a comprehensive solution to LSP floating window dimension issues

local M = {}

-- Safe dimension calculator with multiple fallback strategies
local function get_safe_dimensions()
  local columns = vim.o.columns or vim.api.nvim_get_option_value("columns", {}) or 80
  local lines = vim.o.lines or vim.api.nvim_get_option_value("lines", {}) or 24

  -- Handle edge cases where dimensions might be invalid
  if columns <= 0 or columns == nil then
    columns = 80
  end

  if lines <= 0 or lines == nil then
    lines = 24
  end

  return columns, lines
end

-- Validate and normalize window options
local function normalize_window_opts(opts)
  opts = opts or {}
  local columns, lines = get_safe_dimensions()

  -- Calculate safe dimensions with proper bounds checking
  local safe_max_width = math.max(40, math.min(120, math.floor(columns * 0.8)))
  local safe_max_height = math.max(10, math.min(40, math.floor(lines * 0.8)))

  -- Set or validate width
  if opts.width then
    if type(opts.width) == "number" and opts.width > 0 then
      opts.width = math.min(opts.width, safe_max_width)
    else
      opts.width = nil -- Let LSP calculate it
    end
  end

  -- Set or validate height
  if opts.height then
    if type(opts.height) == "number" and opts.height > 0 then
      opts.height = math.min(opts.height, safe_max_height)
    else
      opts.height = nil -- Let LSP calculate it
    end
  end

  -- Always set safe max dimensions
  opts.max_width = math.max(40, safe_max_width)
  opts.max_height = math.max(10, safe_max_height)

  -- Ensure border is set
  opts.border = opts.border or "rounded"

  return opts
end

-- Patch vim.lsp.util.open_floating_preview with robust error handling
function M.setup()
  local original_open_floating_preview = vim.lsp.util.open_floating_preview

  vim.lsp.util.open_floating_preview = function(contents, syntax, opts)
    -- Normalize options with safe defaults
    opts = normalize_window_opts(opts)

    -- Additional safety: wrap the call in pcall for graceful error handling
    local ok, result = pcall(original_open_floating_preview, contents, syntax, opts)

    if not ok then
      -- If it still fails, try with minimal safe options
      local safe_opts = {
        border = "rounded",
        max_width = 80,
        max_height = 20,
      }

      local ok2, result2 = pcall(original_open_floating_preview, contents, syntax, safe_opts)

      if not ok2 then
        -- Last resort: show error message
        vim.notify("LSP floating window failed to open: " .. tostring(result), vim.log.levels.WARN)
        return nil, nil
      end

      return result2
    end

    return result
  end

  -- Also patch the hover handler for extra safety
  local original_hover_handler = vim.lsp.handlers["textDocument/hover"]
  vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
    if err or not result or not result.contents then
      return original_hover_handler(err, result, ctx, config)
    end

    -- Normalize config for hover
    config = normalize_window_opts(config)

    return original_hover_handler(err, result, ctx, config)
  end
end

-- Auto-setup on module load
M.setup()

return M

