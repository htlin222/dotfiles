local vim = vim
local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand
local portable = require "utils.portable"

local function have_term(term)
	local content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	for _, line in ipairs(content) do
		if string.find(line, term) then
			return true
		end
	end
	return false
end

local function copy_to_blog_folder(keyword)
	if have_term(keyword) then
		local blog_dir = vim.fn.expand("~/Dropbox/blog")
		if not portable.is_dir(blog_dir) then
			return
		end
		local old_filename = vim.fn.expand("%")
		local new_filename = string.gsub(old_filename, keyword, "blog")
		local command = "sed 's/blog_post/blog/g' " .. old_filename .. " > " .. blog_dir .. "/" .. new_filename
		vim.fn.jobstart(command)
		print("📤 Add this note the blog")
	end
end

autocmd({ "BufWritePre" }, {
	group = augroup("blog_post", { clear = true }),
	pattern = "*.md",
	callback = function()
		copy_to_blog_folder("blog_post")
	end,
})
