return {
	"WhoIsSethDaniel/mason-tool-installer.nvim",
	-- event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("mason-tool-installer").setup({
			ensure_installed = {
				{ "bash-language-server", auto_update = true },
				"json-to-struct",
				"lua-language-server",
				"luacheck",
				"misspell",
				"shellcheck",
				"shfmt",
				"stylua",
				"vim-language-server",
				"vint",
				"autopep8",
				"beautysh",
				"black",
				"cmake_link",
				"fixjson",
				"jq",
				"markdownlint",
				"prettier",
				"proselint",
				"pydocstyle",
				"reorder_python_imports",
				"ruff",
				"shellcheck",
				"shfmt",
				"stylua",
				"tidy",
				"yamlfmt",
				"yapf",
			},
			auto_update = false,
			run_on_start = false,
			start_delay = 3000, -- 3 second delay
			debounce_hours = 5, -- at least 5 hours between attempts to install/update
		})
	end,
}
