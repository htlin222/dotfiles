local vim = vim
local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

autocmd({ "BufRead", "BufNewFile" }, {
	group = augroup("Rformat", { clear = true }),
	pattern = "*.R",
	callback = function()
		require("core.utils").load_mappings("nvimR")
	end,
})

autocmd({ "BufRead", "BufNewFile" }, {
	group = augroup("iron", { clear = true }),
	pattern = "*.py",
	callback = function()
		require("core.utils").load_mappings("iron")
		vim.keymap.set("n", "<space>rs", "<cmd>IronRepl<cr>")
		vim.keymap.set("n", "<space>rr", "<cmd>IronRestart<cr>")
		vim.keymap.set("n", "<space>rF", "<cmd>IronFocus<cr>")
		vim.keymap.set("n", "<space>rh", "<cmd>IronHide<cr>")
	end,
})

-- autocmd({ "BufRead", "BufNewFile" }, {
-- 	group = augroup("markdown", { clear = true }),
-- 	pattern = "*.md",
-- 	callback = function() end,
-- })

autocmd({ "BufRead", "BufNewFile" }, {
	group = augroup("bash_and_zsh", { clear = true }),
	pattern = { "*.zsh", "*.env", "*.zshrc" },
	callback = function()
		vim.bo.filetype = "sh"
	end,
})
