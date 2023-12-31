return {
	"mfussenegger/nvim-dap",
	event = "VeryLazy",
	config = function(_, opts)
		require("core.utils").load_mappings("dap")
		vim.fn.sign_define("DapBreakpoint", { text = "✋", texthl = "", linehl = "", numhl = "" })
		vim.fn.sign_define("DapStopped", { text = "👉", texthl = "", linehl = "", numhl = "" })
	end,
}
