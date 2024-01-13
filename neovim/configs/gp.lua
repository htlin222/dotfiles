return {
	"robitx/gp.nvim",
	event = "VeryLazy",
	config = function()
		require("gp").setup()
		-- openai_api_key = { "cat", "path_to/openai_api_key" },
		-- openai_api_key = { "bw", "get", "password", "OPENAI_API_KEY" },
		-- openai_api_key: "sk-...",
		-- openai_api_key = os.getenv("env_name.."),
		-- shortcuts might be setup here (see Usage > Shortcuts in Readme)
	end,
}
