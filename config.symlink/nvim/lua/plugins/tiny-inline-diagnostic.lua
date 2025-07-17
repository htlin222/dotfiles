return {
  "rachartier/tiny-inline-diagnostic.nvim",
  event = "VeryLazy",
  priority = 1000,
  config = function()
    require("tiny-inline-diagnostic").setup({
      -- Show diagnostics after a delay
      throttle = 20,

      -- Blend mode for diagnostic highlights
      blend = {
        factor = 0.27,
      },

      -- Options for diagnostic messages
      options = {
        -- Show diagnostics only on the current line
        show_all_diags = "cursor",
        
        -- Show diagnostics even in insert mode
        show_diag_in_insert = true,
        
        -- Clear diagnostics when entering insert mode
        clear_on_insert = false,
        
        -- Enable multiline diagnostics
        multilines = {
          enabled = true,
          always_show = false,
        },
        
        -- Show diagnostic source (e.g., "typescript", "eslint")
        show_source = true,
        
        -- Format for diagnostic message
        format = function(diagnostic)
          local source = diagnostic.source and string.format("[%s] ", diagnostic.source) or ""
          return string.format("%s%s", source, diagnostic.message)
        end,
        
        -- Severity options
        severity = {
          vim.diagnostic.severity.ERROR,
          vim.diagnostic.severity.WARN,
          vim.diagnostic.severity.INFO,
          vim.diagnostic.severity.HINT,
        },
      },

      -- Signs configuration (in the sign column)
      signs = {
        left = "",
        right = "",
        diag = "●",
        arrow = "    ",
        up_arrow = "    ",
        vertical = " │",
        vertical_end = " └",
      },

      -- Virtual text configuration
      hi = {
        error = "DiagnosticError",
        warn = "DiagnosticWarn",
        info = "DiagnosticInfo",
        hint = "DiagnosticHint",
        arrow = "NonText",
        background = "CursorLine",
        mixing_color = "None",
      },

      -- Disable other diagnostic virtual text to avoid conflicts
      disable_other_diagnostic_virtual_text = true,
    })

    -- Override default diagnostic config to work better with tiny-inline-diagnostic
    vim.diagnostic.config({
      virtual_text = false, -- Disable default virtual text
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = {
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
      },
    })
  end,
}