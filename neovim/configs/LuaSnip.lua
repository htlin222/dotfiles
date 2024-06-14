return { --LuaSnip
	"L3MON4D3/LuaSnip",
	dependencies = "rafamadriz/friendly-snippets",
	event = { "InsertEnter" },
	opts = { history = true, updateevents = "TextChanged,TextChangedI" },
	config = function()
		-- load before require
		vim.g.lua_snippets_path = vim.fn.stdpath("config") .. "/lua/custom/snippets"
		vim.g.vscode_snippets_path = vim.fn.stdpath("config") .. "/lua/custom/vscode_snippets"
		require("plugins.configs.others").luasnip(opts)
		require("custom.snippets")
	end,
}
