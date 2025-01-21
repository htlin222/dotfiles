-- EXAMPLE
local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities
local lspconfig = require "lspconfig"
local servers = {
  -- "ast_grep",
  -- "awk_ls",
  "bashls",
  "cssls",
  -- "harper_ls",
  "html",
  "jsonls",
  "julials",
  "markdown_oxide",
  "pyright",
  "eslint",
  -- "pylsp",
  -- "basedpyright",
  "r_language_server",
  "ruff",
  "ts_ls",
  "vimls",
  "jdtls",
}
-- too slow in large valut"markdown_oxide",
capabilities.workspace = {
  didChangeWatchedFiles = {
    dynamicRegistration = true,
  },
}
-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  }
end

require("lspconfig").lua_ls.setup {
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

-- require("lspconfig").markdown_oxide.setup {
--   filetypes = {
--     "quarto",
--   },
-- }
