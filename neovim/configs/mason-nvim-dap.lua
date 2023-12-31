return {
	"jay-babu/mason-nvim-dap.nvim",
	dependencies = "williamboman/mason.nvim",
	config = function()
		require("mason-nvim-dap").setup({
			ensure_installed = { "debugpy", "bash-debug-adapter" },
		})
	end,
}
