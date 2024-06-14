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

autocmd("BufWritePost", {
	group = augroup("update_date", { clear = true }),
	callback = function()
		-- Define the date pattern to search for, allowing both "date" and "Date". The pattern starts with "date: " or "Date: " and includes double quotes
		local date_pattern = '[dD]ate: "%d%d%d%d%-%d%d%-%d%d"'

		-- Get today's date in the format "YYYY-MM-DD"
		local today = os.date("%Y-%m-%d")

		-- Iterate through each line in the buffer
		for line_number = 1, vim.api.nvim_buf_line_count(0) do
			local line = vim.api.nvim_buf_get_lines(0, line_number - 1, line_number, false)[1]

			-- Check if the line contains the date pattern
			if line:match(date_pattern) then
				-- Replace the date with today's date, keeping the double quotes and case of "date"/"Date"
				local new_line = line:gsub(date_pattern, function(match)
					local date_prefix = match:sub(1, 4) -- Capture 'date' or 'Date'
					return date_prefix .. ': "' .. today .. '"'
				end)
				vim.api.nvim_buf_set_lines(0, line_number - 1, line_number, false, { new_line })
				print("✨苟日新日日新又日新🗓️")
			end
		end
	end,
})
