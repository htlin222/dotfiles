return {
	"lewis6991/hover.nvim",
	keys = "K",
	config = function()
		require("hover").setup({
			init = function()
				require("hover.providers.lsp")
				-- require('hover.providers.gh')
				-- require('hover.providers.gh_user')
				require("hover.providers.man")
				require("hover.providers.dictionary")
				-- custom hover, call api, then get the result
				-- require('custom.config.hover.dadjoke')
			end,
			preview_opts = {
				border = nil,
			},
			-- Whether the contents of a currently open hover window should be moved
			-- to a :h preview-window when pressing the hover keymap.
			preview_window = false,
			title = true,
		})

		-- Setup keymaps
		require("core.utils").load_mappings("hover")
	end,
}
