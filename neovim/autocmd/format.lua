local vim = vim
local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

local function add_vscode_snippet(vscode_snippets_file)
	local first_lines = vim.api.nvim_buf_get_lines(0, 0, 10, false)
	if table.concat(first_lines):match("prefix:") then
		local filename = vim.fn.expand("%:t")
		local command = string.format('python ~/pyscripts/add_py_snippet.py "%s" %s', filename, vscode_snippets_file)
		vim.fn.system(command)
		-- print(command)
		print("Add Prefix 🥰")
	end
end

-- Align Comments in Neovim, ignoring lines that are Markdown hyperlink references
local function align_comments()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local max_comment_start = 0
	local comment_block = {}
	local new_lines = {}
	local is_markdown_link = false

	for _, line in ipairs(lines) do
		-- Check if the line is a Markdown hyperlink reference
		is_markdown_link = string.match(line, "%[%w+%s*.*%]%(%#%w+%-.*%)")

		if not is_markdown_link and not string.match(line, "^%s*#") then
			local comment_start = string.find(line, "#")
			if comment_start then
				max_comment_start = math.max(max_comment_start, comment_start)
				table.insert(comment_block, line)
			else
				if #comment_block > 0 then
					for _, aligned_line in ipairs(align_comment_block(comment_block, max_comment_start)) do
						table.insert(new_lines, aligned_line)
					end
					comment_block = {}
					max_comment_start = 0
				end
				table.insert(new_lines, line)
			end
		else
			if #comment_block > 0 then
				-- Align comments before the Markdown link or full-line comment
				for _, aligned_line in ipairs(align_comment_block(comment_block, max_comment_start)) do
					table.insert(new_lines, aligned_line)
				end
				comment_block = {}
				max_comment_start = 0
			end
			table.insert(new_lines, line) -- Add the Markdown link or full-line comment as is
		end
	end

	if #comment_block > 0 then
		for _, aligned_line in ipairs(align_comment_block(comment_block, max_comment_start)) do
			table.insert(new_lines, aligned_line)
		end
	end

	vim.api.nvim_buf_set_lines(0, 0, -1, false, new_lines)
end

function align_comment_block(comment_block, max_comment_start)
	local aligned_block = {}
	for _, line in ipairs(comment_block) do
		local code, comment = unpack(vim.split(line, "#", true))
		comment = string.gsub(comment, "^%s+", "")
		local aligned_line = string.format("%-" .. max_comment_start .. "s# %s", code, comment)
		table.insert(aligned_block, aligned_line)
	end
	return aligned_block
end

autocmd("BufWritePost", {
	group = augroup("R_fomrat", { clear = true }),
	pattern = "*.R",
	callback = function()
		local file = vim.fn.expand("%:p")
		local cmd = "Rscript $HOME/.dotfiles/neovim/func/styler_i_INPUT.R " .. file
		vim.cmd("silent! RSend system('clear')")
		vim.cmd("silent ! " .. cmd) -- Run the command
		align_comments()
		add_vscode_snippet("~/.dotfiles/neovim/vscode_snippets/r.json")
	end,
})

-- BUG: Why not work in .sh?
autocmd("BufWritePost", {
	group = augroup("snippets", { clear = true }),
	pattern = "*.R",
	callback = function()
		add_vscode_snippet("~/.dotfiles/neovim/vscode_snippets/r.json")
	end,
})

-- BUG: Why not work in .sh?
autocmd("BufWritePost", {
	group = augroup("snippets", { clear = true }),
	pattern = "*.sh",
	callback = function()
		print("Why")
		add_vscode_snippet("~/.dotfiles/neovim/vscode_snippets/shell.json")
	end,
})

autocmd("BufWritePost", {
	group = augroup("snippets", { clear = true }),
	pattern = { "*.py" },
	callback = function()
		add_vscode_snippet("~/.dotfiles/neovim/vscode_snippets/python.json")
	end,
})

autocmd("BufWritePost", {
	group = augroup("archieved", { clear = true }),
	pattern = "*.md",
	callback = function()
		if vim.fn.expand("%:t") == "todo_list.md" then
			local path = vim.fn.expand("%:p") -- 獲取當前檔案的完整路徑
			local archive_path = vim.fn.expand("~/Dropbox/inbox/archieved.md") -- 處理~符號，指定存檔目錄和檔案名稱
			local lines = vim.fn.readfile(path) -- 讀取當前檔案的所有行
			local archive_index = nil
			for i, line in ipairs(lines) do
				if line == "## [[archieved.md|archieved]]" then
					archive_index = i
					break
				end
			end

			if archive_index then
				local date = os.date("%Y-%m-%d")
				-- local subtitle = "## " .. date .. "\n"
				local content_to_archive = table.concat(lines, "\n", archive_index + 1)
				if content_to_archive ~= "" then
					-- content_to_archive = subtitle .. content_to_archive .. "\n"
					content_to_archive = content_to_archive .. "\n"
					-- 附加到存檔檔案
					local f = io.open(archive_path, "a")
					f:write(content_to_archive)
					f:close()
					-- 從原檔案中移除已存檔的內容
					vim.api.nvim_buf_set_lines(0, archive_index, -1, false, {})
					print("Content archived to " .. archive_path)
				else
					print("No content to archive.")
				end
			else
				print("Archive marker not found.")
			end
		end
	end,
})
