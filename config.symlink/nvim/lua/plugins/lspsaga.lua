local vim = vim
return {
  "glepnir/lspsaga.nvim",
  event = { "LspAttach" },
  dependencies = {
    { "nvim-tree/nvim-web-devicons" },
    --Please make sure you install markdown and markdown_inline parser
    { "nvim-treesitter/nvim-treesitter" },
  },
  config = function()
    require("lspsaga").setup {
      diagnostic = {
        on_insert = false,
      },
    }
    vim.api.nvim_set_keymap(
      "n",
      "<leader>ca",
      "<cmd>Lspsaga code_action<CR>",
      { desc = "Lspsaga code_action", noremap = true, silent = true }
    )
  end,
}
