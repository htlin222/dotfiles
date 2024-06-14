return { --chatgpt
	"jackMort/ChatGPT.nvim",
	event = "VeryLazy",
	-- keys = "<leader>cc",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		require("chatgpt").setup({
			api_key_cmd = "op read op://Dev/chat_GPT/api\\ key",
		})
	end,
}
