-- [smjonas/inc-rename.nvim: Incremental LSP renaming based on Neovim's command-preview feature.](https://github.com/smjonas/inc-rename.nvim)
return {
	"smjonas/inc-rename.nvim",
	config = function()
		require("inc_rename").setup()
	end,
}
