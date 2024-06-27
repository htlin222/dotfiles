local vim = vim
return {
  "ellisonleao/carbon-now.nvim",
  lazy = true,
  cmd = "CarbonNow",
  ---@param opts cn.ConfigSchema
  config = function()
    require("carbon-now").setup {
      theme = "One Dark",
      font_family = "JetBrains Mono",
    }
    vim.keymap.set("v", "<leader>cn", ":CarbonNow<CR>", { silent = true })
  end,
}
