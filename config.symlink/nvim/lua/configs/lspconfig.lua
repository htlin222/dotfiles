-- EXAMPLE
local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"
local servers =
  { "html", "cssls", "tsserver", "ruff_lsp", "pyright", "jsonls", "bashls", "vimls", "r_language_server", "julials" }
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
