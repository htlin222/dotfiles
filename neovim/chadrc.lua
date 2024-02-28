---@class ChadrcConfig
local M = {}

--   following this order
M.ui = {
	theme = "dark_horizon",
	lsp = {
		-- show function signatures i.e args as you type
		signature = {
			disabled = true,
			silent = true, -- silences 'no signature help available' message from appearing
		},
	},
}
M.mappings = require("custom.mappings")
M.func = require("custom.func")
M.autocmd = require("custom.autocmd")
M.plugins = "custom.plugins"
-- M.configs = "custom.override"

return M
