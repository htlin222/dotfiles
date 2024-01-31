return {
	"Exafunction/codeium.nvim",
	ft = { "python", "R", "r", "css", "lua" },
	dependencies = {
		"nvim-lua/plenary.nvim",
		"hrsh7th/nvim-cmp",
	},
	config = function()
		require("codeium").setup({})
	end,
}
