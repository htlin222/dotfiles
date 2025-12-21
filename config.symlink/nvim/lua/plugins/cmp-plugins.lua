-- 獨立配置 cmp-plugins，只在編輯 lua 文件時載入
return {
  "KadoBOT/cmp-plugins",
  ft = "lua",
  config = function()
    require("cmp-plugins").setup {
      files = { ".*\\.lua" },
    }
  end,
}
