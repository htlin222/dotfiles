return {
	"nullchilly/fsread.nvim",
	cmd = "FSToggle",
	config = function()
		vim.api.nvim_set_hl(0, "FSPrefix", { fg = "#fcba03" })
		vim.api.nvim_set_hl(0, "FSSuffix", { fg = "#6C7086" })
	end,
}
