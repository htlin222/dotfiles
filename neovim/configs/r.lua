-- https://github.com/jamespeapen/Nvim-R/wiki/Use
return {
	"jalvesaq/Nvim-R",
	lazy = false, -- must set this line
	config = function()
		local vim = vim
		-- vim.g.R_assign_map = "--" -- LuaSnip might be better
		vim.g.R_auto_start = 2
		vim.R_objbr_auto_start = 1
		vim.g.R_assign = 0
		vim.g.R_show_args = 1
		vim.g.R_rconsole_width = 1000
		vim.g.R_min_editor_width = 80
		vim.g.R_args = { "--no-save", "--quiet" }
		vim.g.R_csv_app = "tmux split-window -h vd"
	end,
}
