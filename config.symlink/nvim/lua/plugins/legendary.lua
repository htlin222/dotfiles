return{
  'mrjones2014/legendary.nvim',
  -- 延遲加載以提升啟動性能，在需要時才載入命令面板
  lazy = true,
  cmd = { "Legendary" },
  keys = {
    { "<leader>lg", "<cmd>Legendary<cr>", desc = "Open Legendary" },
  },
  -- sqlite is only needed if you want to use frecency sorting
  -- dependencies = { 'kkharji/sqlite.lua' }
}
