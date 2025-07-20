-- EXAMPLE
local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities
local lspconfig = require "lspconfig"
-- 將常用的輕量級LSP服務器分離出來
local lightweight_servers = {
  "bashls",
  "cssls",
  "html",
  "jsonls",
  "vimls",
}

-- 重型LSP服務器，按需加載
local heavy_servers = {
  julials = { "julia" },
  eslint = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  pylsp = { "python" },
  r_language_server = { "r", "rmd", "quarto" },
  ruff = { "python" },
  ts_ls = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  tailwindcss = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  jdtls = { "java" },
}
-- too slow in large valut"markdown_oxide",
capabilities.workspace = {
  didChangeWatchedFiles = {
    dynamicRegistration = false,
  },
}
-- 設置輕量級LSP服務器（始終加載）
for _, lsp in ipairs(lightweight_servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
    flags = {
      debounce_text_changes = 1000, -- 增加防抖動時間到1秒，大幅減少LSP請求
    },
  }
end

-- 設置重型LSP服務器（按需加載）
for lsp, filetypes in pairs(heavy_servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
    filetypes = filetypes, -- 只在特定文件類型時加載
    flags = {
      debounce_text_changes = 1000, -- 增加防抖動時間到1秒，大幅減少LSP請求
    },
  }
end

require("lspconfig").lua_ls.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  flags = {
    debounce_text_changes = 1000,
  },
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
}
require("lspconfig").groovyls.setup {
  cmd = { "java", "-jar", "/usr/local/opt/groovysdk/libexec/lib/groovy-4.0.8.jar" },
  filetypes = {
    "groovy",
  },
}

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  update_in_insert = false, -- 避免插入模式時過度更新
  signs = true,
  virtual_text = false,
})

-- Load robust LSP floating window fix
require("configs.lsp-floating-fix")

-- Configure Air LSP as custom server (since it may not be in nvim-lspconfig yet)
local configs = require('lspconfig.configs')
if not configs.air then
  configs.air = {
    default_config = {
      cmd = { vim.fn.expand('~/.local/share/nvim/mason/bin/air'), 'language-server' },
      filetypes = { 'r', 'rmd', 'quarto' },
      root_dir = function(fname)
        return lspconfig.util.find_git_ancestor(fname) or vim.fn.getcwd()
      end,
      settings = {},
    },
  }
end

-- Setup Air LSP with formatting on save
require("lspconfig").air.setup({
  on_attach = function(client, bufnr)
    -- Apply default on_attach behavior
    on_attach(client, bufnr)
    
    -- Set up automatic formatting on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ timeout_ms = 3000 })
      end,
    })
  end,
  on_init = on_init,
  capabilities = capabilities,
  flags = {
    debounce_text_changes = 1000,
  },
})

-- Disable r_language_server formatting to avoid conflicts with Air
require("lspconfig").r_language_server.setup({
  on_attach = function(client, bufnr)
    -- Apply default on_attach behavior
    on_attach(client, bufnr)
    
    -- Disable formatting capabilities to let Air handle it
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
  on_init = on_init,
  capabilities = capabilities,
  filetypes = { "r", "rmd", "quarto" },
  flags = {
    debounce_text_changes = 1000,
  },
})

-- require("lspconfig").markdown_oxide.setup {
--   filetypes = {
--     "quarto",
--   },
-- }
