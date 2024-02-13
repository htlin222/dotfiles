---@class ChadrcConfig
local M = {}

--   following this order
M.ui = { theme = "ayu_dark" }
M.mappings = require("custom.mappings")
M.func = require("custom.func")
M.autocmd = require("custom.autocmd")
M.plugins = "custom.plugins"
-- M.configs = "custom.override"

return M
