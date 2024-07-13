return {
  "sontungexpt/better-diagnostic-virtual-text",
  event = "LspAttach",
  config = function(_)
    vim.diagnostic.config { virtual_text = false } -- for tiny lsp
    require("better-diagnostic-virtual-text").setup {
      inline = true,
    }
  end,
}
