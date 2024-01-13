local vim = vim
local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

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
	group = augroup("align", { clear = true }),
	pattern = { "*.R", "*.py", "*.md" },
	callback = function()
		align_comments()
	end,
})

autocmd("BufWritePost", {
	group = augroup("R_fomrat", { clear = true }),
	pattern = "*.R",
	callback = function()
		-- vim.cmd("w")
		local file = vim.fn.expand("%:p")
		local cmd = "Rscript $HOME/.dotfiles/neovim/func/styler_i_INPUT.R " .. file
		vim.cmd("echo 'DONE'")
		vim.cmd("silent ! " .. cmd) -- Run the command
	end,
})
