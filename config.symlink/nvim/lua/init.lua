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
if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  -- 使用 git 克隆 lazy.nvim 倉庫到指定路徑
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

-- 將 lazy.nvim 路徑添加到 Neovim 的運行時路徑中，使其可以被加載
vim.opt.rtp:prepend(lazypath)

-- 載入 lazy.nvim 的配置文件
local lazy_config = require "configs.lazy"

-- 優化：異步檢測WezTerm，避免阻塞啟動
local is_wezterm = os.getenv "WEZTERM_EXECUTABLE" ~= nil


-- 統一的lazy.nvim設置，移除WezTerm條件分支以簡化啟動
require("lazy").setup({
  {
    -- 加載 NvChad 核心插件
    "NvChad/NvChad",
    lazy = false,  -- 核心插件需要立即加載
    branch = "v2.5",  -- 使用 v2.5 分支
    import = "nvchad.plugins",  -- 導入 NvChad 的插件
    config = function()
      -- 延遲加載基本選項設置，提升啟動速度
      vim.schedule(function()
        require "options"
      end)
    end,
  },

  -- 導入用戶自定義插件
  { import = "plugins" },
}, lazy_config)

-- 優化：異步加載主題和狀態欄配置
vim.schedule(function()
  -- 檢查文件是否存在再加載，避免錯誤
  local defaults_file = vim.g.base46_cache .. "defaults"
  local statusline_file = vim.g.base46_cache .. "statusline"
  
  if vim.uv.fs_stat(defaults_file) then
    dofile(defaults_file)
  end
  
  if vim.uv.fs_stat(statusline_file) then
    dofile(statusline_file)
  end
end)

-- 優化：延遲加載自動命令和按鍵映射，提升啟動速度
vim.schedule(function()
  -- 延遲加載 NvChad 的自動命令
  require "nvchad.autocmds"
  -- 延遲加載按鍵映射
  require "mappings"
end)
