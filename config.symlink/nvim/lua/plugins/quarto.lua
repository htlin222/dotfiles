return {
	"quarto-dev/quarto-nvim",
	dev = false,
	ft = { "python", "r", "R", "quarto" },
	dependencies = {
		{
			"jmbuhr/otter.nvim",
			dev = false,
			dependencies = {
				{ "neovim/nvim-lspconfig" },
			},
			opts = {
				buffers = {
					-- if set to true, the filetype of the otterbuffers will be set.
					-- otherwise only the autocommand of lspconfig that attaches
					-- the language server will be executed without setting the filetype
					set_filetype = true,
				},
			},
		},
	},
	config = function()
		require("quarto").setup({
			debug = false,
			closePreviewOnExit = true,
			lspFeatures = {
				enabled = true,
				languages = { "r", "python", "julia", "bash" },
				chunks = "curly", -- 'curly' or 'all'
				diagnostics = {
					enabled = true,
					triggers = { "BufWritePost" },
				},
				completion = {
					enabled = true,
				},
			},
			codeRunner = {
				enabled = false,
				default_method = nil, -- 'molten' or 'slime'
				ft_runners = {}, -- filetype to runner, ie. `{ python = "molten" }`.
				-- Takes precedence over `default_method`
				never_run = { "yaml" }, -- filetypes which are never sent to a code runner
			},
			keymap = {
				hover = "K",
				definition = "gd",
				rename = "<leader>lR",
				references = "gr",
			},
		})
	end,
}
