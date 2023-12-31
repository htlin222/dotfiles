local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand
autocmd("InsertEnter", {
	group = augroup("InsertBefore", { clear = true }),
	callback = function()
		if Boshiamy then
			vim.fn.system("fcitx5-remote -t")
			-- vim.fn.system("im-select com.boshiamy.inputmethod.BoshiamyIMK")
		end
	end,
})

-- switch to ABC when back to normal mode
autocmd("InsertLeavePre", {
	group = augroup("IMswitch", { clear = true }),
	callback = function()
		-- local im_select_output = vim.fn.system("im-select")
		local output = vim.fn.system("fcitx5-remote")
		local fcitx5_output = string.gsub(output, "\n", "")
		if fcitx5_output == "1" then
			Boshiamy = true
			vim.fn.system("fcitx5-remote -t")
		else
			Boshiamy = false
		end
	end,
})
