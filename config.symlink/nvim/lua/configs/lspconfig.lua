-- Neovim 0.11+ LSP Configuration using vim.lsp.config API
local nvchad_lsp = require("nvchad.configs.lspconfig")
local on_attach = nvchad_lsp.on_attach
local on_init = nvchad_lsp.on_init
local capabilities = nvchad_lsp.capabilities

-- 禁用文件監視以提升性能
capabilities.workspace = {
  didChangeWatchedFiles = {
    dynamicRegistration = false,
  },
}

-- 全局 LSP 設置（適用於所有服務器）
vim.lsp.config("*", {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  flags = {
    debounce_text_changes = 1000, -- 增加防抖動時間到1秒，大幅減少LSP請求
  },
})

-- 輕量級 LSP 服務器（始終加載）
local lightweight_servers = {
  "bashls",
  "cssls",
  "html",
  "jsonls",
  "vimls",
}

-- 重型 LSP 服務器配置
-- julials
vim.lsp.config("julials", {
  filetypes = { "julia" },
})

-- eslint
vim.lsp.config("eslint", {
  filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
})

-- pylsp
vim.lsp.config("pylsp", {
  filetypes = { "python" },
})

-- ruff
vim.lsp.config("ruff", {
  filetypes = { "python" },
})

-- ts_ls (TypeScript)
vim.lsp.config("ts_ls", {
  filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
})

-- tailwindcss
vim.lsp.config("tailwindcss", {
  filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
})

-- jdtls (Java)
vim.lsp.config("jdtls", {
  filetypes = { "java" },
})

-- lua_ls 配置
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
})

-- groovyls 配置
vim.lsp.config("groovyls", {
  cmd = { "java", "-jar", "/usr/local/opt/groovysdk/libexec/lib/groovy-4.0.8.jar" },
  filetypes = { "groovy" },
})

-- Air LSP 配置 (R 語言格式化)
vim.lsp.config("air", {
  cmd = { vim.fn.expand("~/.local/share/nvim/mason/bin/air"), "language-server" },
  filetypes = { "r", "rmd" }, -- quarto excluded: uses injected formatter
  root_markers = { ".git", "DESCRIPTION", ".Rproj" },
  on_attach = function(client, bufnr)
    -- 調用默認的 on_attach
    on_attach(client, bufnr)
    -- 設置保存時自動格式化
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ timeout_ms = 3000 })
      end,
    })
  end,
})

-- r_language_server 配置（禁用格式化以避免與 Air 衝突）
vim.lsp.config("r_language_server", {
  filetypes = { "r", "rmd", "quarto" },
  on_attach = function(client, bufnr)
    -- 調用默認的 on_attach
    on_attach(client, bufnr)
    -- 禁用格式化功能讓 Air 處理
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
})

-- 診斷設置
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  update_in_insert = false, -- 避免插入模式時過度更新
  signs = true,
  virtual_text = false,
})

-- 載入浮動窗口修復
require("configs.lsp-floating-fix")

-- 啟用所有 LSP 服務器
local all_servers = {
  -- 輕量級
  "bashls",
  "cssls",
  "html",
  "jsonls",
  "vimls",
  -- 重型
  "julials",
  "eslint",
  -- "pylsp", -- disabled: use ruff instead (faster, modern)
  "ruff",
  "ts_ls",
  "tailwindcss",
  "jdtls",
  -- 特殊配置
  "lua_ls",
  "groovyls",
  "air",
  -- "r_language_server", -- disabled: use air instead
}

vim.lsp.enable(all_servers)
