return {
	"HiPhish/rainbow-delimiters.nvim",
	event = "VeryLazy",
	config = function()
		require("rainbow-delimiters.setup").setup({
			strategy = {
				-- ...
			},
			query = {
				-- ...
			},
			highlight = {
				-- ...
			},
		})
	end,
}
