-- neoclip in plugin list
-- [AckslD/nvim-neoclip.lua: Clipboard manager neovim plugin with telescope integration](https://github.com/AckslD/nvim-neoclip.lua)
return {
	"AckslD/nvim-neoclip.lua",
	dependencies = {
		-- you'll need at least one of these
		{ "nvim-telescope/telescope.nvim" },
		-- {'ibhagwan/fzf-lua'},
	},
	config = function()
		require("neoclip").setup()
	end,
}
