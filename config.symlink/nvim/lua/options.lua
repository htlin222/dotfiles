if not vim.g.vscode then
  require "nvchad.options"
end
local vim = vim
local opt = vim.opt
local wo = vim.wo

-- 開始設定選項 (start option)
opt.cursorlineopt = "both" -- 設定游標行的突出顯示方式，包括行號和文本
opt.autoindent = true -- 啟用自動縮排
opt.autochdir = true -- 自動切換工作目錄到當前文件所在目錄
opt.lbr = true -- 啟用換行不分割單詞 (linebreak 的縮寫)
opt.expandtab = true -- 將 Tab 轉換為空格
opt.shiftround = false -- 不將縮排對齊到 shiftwidth 的倍數
opt.wrap = true -- 啟用自動換行
opt.linebreak = true -- 在單詞邊界處換行
opt.textwidth = 80 -- 設定文本寬度為 80 個字符
opt.shiftwidth = 2 -- 縮排寬度為 2 個空格

opt.spell = false -- 拼寫檢查預設關閉，在特定文件類型中啟用
opt.spelllang = { "en_us" } -- 設定拼寫檢查語言為美式英語
opt.smartindent = true -- 啟用智能縮排
opt.softtabstop = 2 -- 編輯時 Tab 鍵的寬度為 2 個空格
opt.swapfile = false -- 不創建交換文件
opt.scrolloff = 10 -- 保持游標上下至少有 10 行可見
opt.sidescrolloff = 8 -- 保持游標左右至少有 8 列可見
opt.ttimeoutlen = 5 -- 終端按鍵碼超時時間為 5 毫秒
opt.timeoutlen = 1000 -- 按鍵映射超時時間為 1000 毫秒
opt.updatetime = 1000 -- CursorHold 事件觸發時間為 1000 毫秒（優化性能）
opt.tabstop = 2 -- Tab 字符顯示寬度為 2 個空格
opt.colorcolumn = "60,80,120" -- 只在第 80 列和 120 列顯示垂直參考線（優化性能）
vim.api.nvim_set_hl(0, "ColorColumn", { link = "CursorLine" })
wo.relativenumber = true -- 啟用相對行號
vim.cmd [[highlight ColorColumn ctermbg=235 guibg=#2c2d27]] -- 設定參考線顏色
vim.g.did_load_netrw = 1 -- 禁用 Netrw 文件瀏覽器
vim.markdown_folding = 1 -- 啟用 Markdown 文件折疊
vim.cmd [[highlight NotifyBackground guibg=#1e1e1e]] -- 設定背景顏色

-- 跨平台剪貼板配置 (cross-platform clipboard)
-- 優先順序：
-- 1. SSH/tmux 環境 → OSC 52（直接透過終端傳到本機）
-- 2. macOS → pbcopy/pbpaste
-- 3. Linux Wayland → wl-copy/wl-paste
-- 4. Linux X11 → xclip 或 xsel
local function setup_clipboard()
  local is_ssh = vim.env.SSH_TTY ~= nil or vim.env.SSH_CLIENT ~= nil
  local is_tmux = vim.env.TMUX ~= nil
  local is_wayland = vim.env.WAYLAND_DISPLAY ~= nil
  local is_mac = vim.fn.has("mac") == 1

  -- SSH/tmux 環境優先使用 OSC 52（即使有 xclip 也用不到本機剪貼板）
  if is_ssh or is_tmux then
    vim.g.clipboard = {
      name = "OSC 52",
      copy = {
        ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
        ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
      },
      paste = {
        ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
        ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
      },
    }
  elseif is_mac then
    vim.g.clipboard = {
      name = "macOS-clipboard",
      copy = {
        ["+"] = "pbcopy",
        ["*"] = "pbcopy",
      },
      paste = {
        ["+"] = "pbpaste",
        ["*"] = "pbpaste",
      },
      cache_enabled = 0,
    }
  elseif is_wayland and vim.fn.executable("wl-copy") == 1 then
    vim.g.clipboard = {
      name = "wayland-clipboard",
      copy = {
        ["+"] = "wl-copy --foreground --type text/plain",
        ["*"] = "wl-copy --foreground --type text/plain --primary",
      },
      paste = {
        ["+"] = "wl-paste --no-newline",
        ["*"] = "wl-paste --no-newline --primary",
      },
      cache_enabled = 0,
    }
  elseif vim.fn.executable("xclip") == 1 then
    vim.g.clipboard = {
      name = "xclip",
      copy = {
        ["+"] = "xclip -selection clipboard",
        ["*"] = "xclip -selection primary",
      },
      paste = {
        ["+"] = "xclip -selection clipboard -o",
        ["*"] = "xclip -selection primary -o",
      },
      cache_enabled = 0,
    }
  elseif vim.fn.executable("xsel") == 1 then
    vim.g.clipboard = {
      name = "xsel",
      copy = {
        ["+"] = "xsel --clipboard --input",
        ["*"] = "xsel --primary --input",
      },
      paste = {
        ["+"] = "xsel --clipboard --output",
        ["*"] = "xsel --primary --output",
      },
      cache_enabled = 0,
    }
  end
end

setup_clipboard()

-- 立即加載自動命令配置，確保 BufNewFile 事件能正常觸發
require "autocmd"
