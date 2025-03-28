local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

autocmd("InsertEnter", {
	group = augroup("InsertBefore", { clear = true }),
	callback = function()
		if Boshiamy then
			vim.fn.system("im-select com.boshiamy.inputmethod.BoshiamyIMK")
		end
	end,
})

-- Replace in macos.lua
autocmd("InsertLeavePre", {
	group = augroup("IMswitch", { clear = true }),
	callback = function()
		-- Use a more efficient way to detect input method
		-- Only switch if needed
		local im_select_output = vim.fn.system("im-select")
		if not im_select_output:match("ABC") then
			Boshiamy = true
			-- Use vim.schedule to make this non-blocking
			vim.schedule(function()
				vim.fn.system("im-select com.apple.keylayout.ABC")
			end)
		else
			Boshiamy = false
		end
	end,
})
