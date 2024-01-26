return { --mkdnflow
	"jakewvincent/mkdnflow.nvim",
	ft = { "markdown" },
	-- lazy = true,
	config = function()
		-- by default, the fold method was set by tree-sitter expr
		vim.opt.foldmethod = "manual"
		vim.opt.foldlevel = 3
		vim.cmd("source $HOME/.config/nvim/lua/custom/func/mdfmt.vim")
		vim.cmd("source $HOME/.config/nvim/lua/custom/func/mdmain.vim")
		require("core.utils").load_mappings("mkdn")
		require("mkdnflow").setup({
			modules = {
				bib = true,
				buffers = true,
				conceal = true,
				cursor = true,
				folds = false,
				links = true,
				lists = true,
				maps = true,
				paths = true,
				tables = true,
				-- yaml = true,
			},
			filetypes = { md = true, rmd = true, markdown = true, telekasten = true, vimiwki = true },
			perspective = {
				priority = "current",
				fallback = "root",
				root_tell = "~/Dropbox/Medical/",
				nvim_wd_heel = false,
				update = false,
			},
			wrap = true,
			bib = {
				default_path = "~/Downloads/test.bib",
				find_in_root = true,
			},
			silent = false,
			links = {
				style = "wiki",
				-- name_is_source = true,
				conceal = true,
				context = 0,
				implicit_extension = nil,
				transform_implicit = false,
				-- transform_explicit = false,
				transform_explicit = function(text)
					-- text = text:gsub(" ", "-")
					text = text:lower()
					-- text = os.date('%Y-%m-%d_')..text
					return text
				end,
			},
			to_do = {
				symbols = { " ", "x", "X" },
				update_parents = true,
				not_started = " ",
				in_progress = "x",
				complete = "X",
			},
			create_dirs = true,
			mappings = {
				MkdnEnter = { { "v" }, "<CR>" },
				MkdnTab = false,
				MkdnSTab = false,
				MkdnNextLink = { "n", "<Tab>" },
				MkdnPrevLink = { "n", "<S-Tab>" },
				MkdnNextHeading = { "n", "]]" },
				MkdnPrevHeading = { "n", "[[" },
				MkdnGoBack = { "n", "<BS>" },
				MkdnGoForward = { "n", "<Del>" },
				MkdnCreateLink = false, -- see MkdnEnter
				MkdnCreateLinkFromClipboard = { { "v" }, "<C-j>" }, -- see MkdnEnter
				MkdnFollowLink = false, -- see MkdnEnter
				MkdnDestroyLink = { "n", "<leader>d" },
				MkdnTagSpan = { "v", "<M-CR>" },
				MkdnMoveSource = { "n", "<F2>" },
				MkdnYankAnchorLink = { "n", "yaa" },
				MkdnYankFileAnchorLink = { "n", "yfa" },
				MkdnIncreaseHeading = { "n", "-" },
				MkdnDecreaseHeading = { "n", "=" },
				MkdnToggleToDo = { { "n", "v" }, "<leader>to" },
				MkdnNewListItem = false,
				MkdnNewListItemBelowInsert = { "n", "o" },
				MkdnNewListItemAboveInsert = { "n", "O" },
				MkdnExtendList = false,
				MkdnUpdateNumbering = { "n", "<leader>nn" },
				-- MkdnTableNextCell = { "i", "<Tab>" },
				-- MkdnTablePrevCell = { "i", "<S-Tab>" },
				MkdnTableNextRow = false,
				MkdnTablePrevRow = { "i", "<M-CR>" },
				MkdnTableNewRowBelow = { "n", "<leader>ir" },
				MkdnTableNewRowAbove = { "n", "<leader>iR" },
				MkdnTableNewColAfter = { "n", "<leader>ic" },
				MkdnTableNewColBefore = { "n", "<leader>iC" },
				MkdnFoldSection = { "n", "<leader>zq" },
			},
		})
	end,
}
