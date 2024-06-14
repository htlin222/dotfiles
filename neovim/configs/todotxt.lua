return {
	"arnarg/todotxt.nvim",
	event = "VeryLazy",
	dependencies = { "MunifTanjim/nui.nvim" },
	config = function()
		require("todotxt-nvim").setup({
			todo_file = "~/Dropbox/todo.txt",
		})
	end,
}
