return {
	"Exafunction/codeium.nvim",
	ft = { "python", "R", "r", "css", "lua", "sh", "md", "zsh" },
	dependencies = {
		"nvim-lua/plenary.nvim",
		"hrsh7th/nvim-cmp",
	},
	config = function()
		require("codeium").setup({})
	end,
}
