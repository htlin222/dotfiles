return {
  "jmbuhr/otter.nvim",
  ft = { "markdown", "quarto", "norg", "rmd" },
  config = function()
    local otter = require "otter"
    otter.setup {
      verbose = { no_code_found = false },
      lsp = {
        hover = {
          border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
        },
        -- `:h events` that cause the diagnostics to update. Set to:
        -- { "BufWritePost", "InsertLeave", "TextChanged" } for less performant
        -- but more instant diagnostic updates
        diagnostic_update_events = { "BufWritePost" },
      },
      buffers = {
        -- write <path>.otter.<embedded language extension> files
        -- to disk on save of main buffer.
        -- usefule for some linters that require actual files
        -- otter files are deleted on quit or main buffer close
        write_to_disk = false,
      },
      strip_wrapping_quote_characters = { "'", '"', "`" },
      -- Otter may not work the way you expect when entire code blocks are indented (eg. in Org files)
      -- When true, otter handles these cases fully. This is a (minor) performance hit
      handle_leading_whitespace = false,
    }

    -- Activate on filetype enter (deferred to allow treesitter to parse first)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdown", "quarto", "norg", "rmd" },
      callback = function()
        vim.defer_fn(function()
          local languages = { "python", "r", "lua", "bash" }
          local completion = true
          local diagnostics = false
          otter.activate(languages, completion, diagnostics)
        end, 100)
      end,
    })
  end,
}
