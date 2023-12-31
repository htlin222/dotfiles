return { --
	"nvim-neorg/neorg",
	-- lazy = false,
	ft = { "norg" },
	-- event = "VeryLazy",
	-- when enter a buffer
	-- event = { "BufReadPre " .. vim.fn.expand "~" .. "/Documents/Medical/**.md" },
	build = ":Neorg sync-parsers",
	dependencies = { "nvim-lua/plenary.nvim" },
	-- dependencies = {},
	config = function()
		-- vim.keymap.set("n", "<leader>KEY", "<cmd>YOURCMD<CR>")
		require("neorg").setup({
			load = {
				["core.defaults"] = {}, -- Loads default behaviour
				-- https://github.com/nvim-neorg/neorg/wiki#default-modules
				["core.concealer"] = {}, -- Adds pretty icons to your documents
				["core.dirman"] = { -- Manages Neorg workspaces
					config = {
						workspaces = {
							inbox = "~/Dropbox/inbox/",
						},
					},
				},
			},
		})
	end,
}
