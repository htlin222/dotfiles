local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

-- 優化：使用異步jobstart避免阻塞，並添加防抖動機制
local last_im_check = 0
local debounce_delay = 500 -- 500ms防抖動

local function async_im_select(cmd)
	vim.fn.jobstart(cmd, {
		on_exit = function(_, exit_code)
			if exit_code ~= 0 then
				vim.notify("Input method switching failed", vim.log.levels.WARN)
			end
		end,
	})
end

autocmd("InsertEnter", {
	group = augroup("InsertBefore", { clear = true }),
	callback = function()
		local now = vim.loop.now()
		if now - last_im_check < debounce_delay then
			return
		end
		last_im_check = now
		
		if Boshiamy then
			async_im_select("im-select com.boshiamy.inputmethod.BoshiamyIMK")
		end
	end,
})

-- switch to ABC when back to normal mode
autocmd("InsertLeavePre", {
	group = augroup("IMswitch", { clear = true }),
	callback = function()
		local now = vim.loop.now()
		if now - last_im_check < debounce_delay then
			return
		end
		last_im_check = now
		
		-- 異步檢查當前輸入法
		vim.fn.jobstart("im-select", {
			stdout_buffered = true,
			on_stdout = function(_, data)
				local im_select_output = table.concat(data, "")
				if not string.match(im_select_output, "ABC") then
					Boshiamy = true
					async_im_select("im-select com.apple.keylayout.ABC")
				else
					Boshiamy = false
				end
			end,
		})
	end,
})
