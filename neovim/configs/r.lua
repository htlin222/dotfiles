-- https://github.com/jamespeapen/Nvim-R/wiki/Use
return {
	"jalvesaq/Nvim-R",
	lazy = false,
	config = function()
		local vim = vim
		vim.g.R_auto_start = 2
		-- vim.g.R_assign_map = "--"
		vim.g.R_assign = 0
		vim.g.R_show_args = 1
		vim.keymap.set("n", "<CR>", "<Plug>RDSendLine")
		require("core.utils").load_mappings("nvimR")
	end,
}
