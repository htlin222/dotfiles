-- 載入 NvChad 的鍵位映射
if not vim.g.vscode then
  require "nvchad.mappings"
end

-- 載入模組化的按鍵映射
require("mappings.normal")()
require("mappings.insert")()
require("mappings.visual")()
require("mappings.operator")()
require("mappings.plugins")()
require("mappings.autocmd")()