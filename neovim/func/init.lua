local vim = vim
function Print_me()
	print("This is a message from my_module.")
end

function _G.AppendCurrentLine()
	if vim.o.encoding == "" then
		vim.o.encoding = "utf-8"
	end
	local current_line = vim.fn.getline(".")
	-- local trimmed_line = string.sub(current_line, 3)
	local trimmed_line = current_line
	local current_file = vim.fn.expand("%:t")
	local combined_text = "In " .. current_file .. ": " .. trimmed_line
	local append_cmd = ":silent GpAppend " .. combined_text
	vim.cmd(append_cmd)
	print("已產生結果了")
	vim.cmd(":normal!<CR>")
end

function _G.AppendVisualSelection()
	-- 检查是否在 Visual 模式下
	if vim.fn.visualmode() ~= "V" then
		vim.api.nvim_err_writeln("Not in Visual mode")
		return
	end
	local selection = vim.fn.getreg("")
	local append_cmd = ":GpAppend " .. selection
	vim.cmd(append_cmd)
end

function _G.ReloadConfig()
	for name, _ in pairs(package.loaded) do
		if name:match("^user") and not name:match("nvim-tree") then
			package.loaded[name] = nil
		end
	end

	dofile(vim.env.MYVIMRC)
	vim.notify("Nvim configuration reloaded!", vim.log.levels.INFO)
end

function _G.Copy_outline_to_clipboard()
	local current_buffer_file = vim.api.nvim_buf_get_name(0) -- 獲取當前緩衝檔案的名稱
	local command = 'sed -n \'/<!-- _header: "Outline" -->/,/<!-- _footer: "" -->/{/<!-- _header: "Outline" -->/!{/<!-- _footer: "" -->/!p;};}\' '
		.. current_buffer_file
		.. " | pbcopy"
	os.execute(command) -- 執行命令
	print("臭蜥蜴")
end

-- 定義打開當前檔案的函數
function _G.Open_with_default_app()
	local current_file = vim.fn.expand("%:p") -- 獲取當前緩衝區的檔案路徑
	local user_input = vim.fn.input("要打開📂" .. vim.fn.expand("%") .. "嗎? [Y]是 [N]否): ")
	if user_input == "y" then
		local open_command = "open " .. vim.fn.shellescape(current_file)
		vim.fn.system(open_command)
		print("開🔥")
	else
		print("你底心是小小的窗扉緊掩")
	end
end
M = {}
M.print_me = function()
	print("M.print_me = function()")
end

M.say_hello = function(name)
	print("Hello, " .. name .. "!")
end
return M
