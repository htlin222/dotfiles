-- EXAMPLE
local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities
vim.diagnostic.config { virtual_text = false }
local lspconfig = require "lspconfig"
local servers = {
  "ast_grep",
  "awk_ls",
  "bashls",
  "cssls",
  "harper_ls",
  "html",
  "jsonls",
  "julials",
  "markdown_oxide",
  "pyright",
  "r_language_server",
  "ruff_lsp",
  -- "sourcery",
  "tsserver",
  "vimls",
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
require("lspconfig").sourcery.setup {
  init_options = {
    --- The Sourcery token for authenticating the user.
    --- This is retrieved from the Sourcery website and must be
    --- provided by each user. The extension must provide a
    --- configuration option for the user to provide this value.
    token = "user_NDXxUdMGGdlogY8Cnp4Jlbzn1FfAxdDJjHIu8KujfHpqAGuwv06wX6MzQRA",
    --- The extension's name and version as defined by the extension.
    extension_version = "vim.lsp",

    --- The editor's name and version as defined by the editor.
    editor_version = "vim",
  },
}
