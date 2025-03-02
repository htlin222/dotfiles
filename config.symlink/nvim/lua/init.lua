-- 設定 NvChad 快取目錄路徑，用於存儲主題和其他快取文件
vim.g.base46_cache = vim.fn.stdpath "data" .. "/nvchad/base46/"
-- 設定全域的 leader 鍵為空格鍵，這是許多自定義快捷鍵的前綴
vim.g.mapleader = " "

-- 檢查是否在 VSCode 中運行 Neovim
if vim.g.vscode then
  -- 如果在 VSCode 中運行，只載入按鍵映射
  require "mappings"
  return -- 提前退出，不執行後續代碼
end

-- 引導安裝 lazy.nvim 插件管理器和所有插件
-- 定義 lazy.nvim 的安裝路徑
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

-- 檢查 lazy.nvim 是否已安裝，如果沒有則自動安裝
if not vim.loop.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  -- 使用 git 克隆 lazy.nvim 倉庫到指定路徑
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

-- 將 lazy.nvim 路徑添加到 Neovim 的運行時路徑中，使其可以被加載
vim.opt.rtp:prepend(lazypath)

-- 載入 lazy.nvim 的配置文件
local lazy_config = require "configs.lazy"

-- 檢測是否在 WezTerm 終端模擬器中運行
local is_wezterm = os.getenv "WEZTERM_EXECUTABLE" ~= nil

if is_wezterm then
  -- 如果在 WezTerm 中運行，則設置 lazy.nvim 並加載插件
  require("lazy").setup({
    {
      -- 加載 NvChad 核心插件
      "NvChad/NvChad",
      lazy = false,  -- 設為 false 表示立即加載，而不是懶加載
      branch = "v2.5",  -- 使用 v2.5 分支
      import = "nvchad.plugins",  -- 導入 NvChad 的插件
      config = function()
        -- 加載基本選項設置
        require "options"
      end,
    },

    -- 導入用戶自定義插件
    { import = "plugins" },
  }, lazy_config)

  -- 在這裡加入 WezTerm 特定的配置
else
  -- 如果不是在 WezTerm 中運行，則輸出提示信息
  print "Not running inside WezTerm."
  -- 其他配置
end

-- 加載主題和默認設置
dofile(vim.g.base46_cache .. "defaults")
-- 加載狀態欄配置
dofile(vim.g.base46_cache .. "statusline")

-- 加載 NvChad 的自動命令
require "nvchad.autocmds"

-- 使用 vim.schedule 確保在 Neovim 完全啟動後再加載按鍵映射
-- 這可以避免某些初始化問題
vim.schedule(function()
  require "mappings"
end)
