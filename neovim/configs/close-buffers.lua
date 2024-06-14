return {
	"kazhala/close-buffers.nvim",
	keys = {
		{ -- example for lazy-loading on keystroke
			"<leader>tl",
			"<cmd>Twilight<CR>",
			mode = { "n", "o", "x" },
			desc = "Toggle Twilight",
		},
	},
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
	},
	config = function()
		require("close_buffers").setup({
			filetype_ignore = {}, -- Filetype to ignore when running deletions
			file_glob_ignore = {}, -- File name glob pattern to ignore when running deletions (e.g. '*.md')
			file_regex_ignore = {}, -- File name regex pattern to ignore when running deletions (e.g. '.*[.]md')
			preserve_window_layout = { "this", "nameless" }, -- Types of deletion that should preserve the window layout
			next_buffer_cmd = nil, -- Custom function to retrieve the next buffer when preserving window layout
		})
	end,
}
-- -- bdelete
-- require('close_buffers').delete({ type = 'hidden', force = true }) -- Delete all non-visible buffers
-- require('close_buffers').delete({ type = 'nameless' }) -- Delete all buffers without name
-- require('close_buffers').delete({ type = 'this' }) -- Delete the current buffer
-- require('close_buffers').delete({ type = 1 }) -- Delete the specified buffer number
-- require('close_buffers').delete({ regex = '.*[.]md' }) -- Delete all buffers matching the regex
--
-- -- bwipeout
-- require('close_buffers').wipe({ type = 'all', force = true }) -- Wipe all buffers
-- require('close_buffers').wipe({ type = 'other' }) -- Wipe all buffers except the current focused
-- require('close_buffers').wipe({ type = 'hidden', glob = '*.lua' }) -- Wipe all buffers matching the glob
-- [kazhala/close-buffers.nvim: :bookmark_tabs: Delete multiple vim buffers based on different conditions](https://github.com/kazhala/close-buffers.nvim)
