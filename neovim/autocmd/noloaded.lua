-- Define autocommands with Lua APIs
-- See: h:api-autocmd, h:augroup

local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand
augroup("Group_${1:FUNCTION}", { clear = true })
autocmd("${1:}", {
	group = "Group_${1:GROUPNAME}",
	callback = function()
		-- ${2:YOUR CODE HERE}
	end,
})

-- back to previous input Method switch
Boshiamy = false -- default in ABC
autocmd("InsertEnter", {
	group = augroup("InsertBefore", { clear = true }),
	callback = function()
		if Boshiamy then
			vim.fn.system("fcitx5-remote -t")
			vim.fn.system("im-select com.boshiamy.inputmethod.BoshiamyIMK")
			print("hellow")
		end
	end,
})

-- switch to ABC when back to normal mode
autocmd("InsertLeavePre", {
	group = augroup("IMswitch", { clear = true }),
	callback = function()
		local im_select_output = vim.fn.system("im-select")
		local output = vim.fn.system("fcitx5-remote")
		local fcitx5_output = string.gsub(output, "\n", "")
		if (not string.match(im_select_output, "ABC")) or (fcitx5_output == "1") then
			Boshiamy = true
			if not string.match(im_select_output, "ABC") then
				vim.fn.system("im-select com.apple.keylayout.ABC")
			end
			if fcitx5_output == "1" then
				vim.fn.system("fcitx5-remote -t")
			end
		else
			Boshiamy = false
		end
	end,
})
