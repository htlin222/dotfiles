-- [smjonas/inc-rename.nvim: Incremental LSP renaming based on Neovim's command-preview feature.](https://github.com/smjonas/inc-rename.nvim)
return {
	"smjonas/inc-rename.nvim",
	event = "VeryLazy",
	config = function()
		require("inc_rename").setup()
		vim.keymap.set("n", "<leader>rn", function()
			return ":IncRename " .. vim.fn.expand("<cword>")
		end, { expr = true }, { desc = "Rename the words under the cursor" })
	end,
}
