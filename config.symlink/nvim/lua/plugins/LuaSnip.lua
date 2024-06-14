return { --LuaSnip
	"L3MON4D3/LuaSnip",
	dependencies = "rafamadriz/friendly-snippets",
	event = { "InsertEnter" },
	opts = { history = true, updateevents = "TextChanged,TextChangedI" },
	config = function()
		require("lua_snippets")
	end,
}
