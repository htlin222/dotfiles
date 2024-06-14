return {
	"malbertzard/inline-fold.nvim",
	opts = {
		defaultPlaceholder = "…",
		queries = {
			-- Some examples you can use
			html = {
				{ pattern = 'class="([^"]*)"', placeholder = "@" }, -- classes in html
				{ pattern = 'href="(.-)"' }, -- hrefs in html
				{ pattern = 'src="(.-)"' }, -- HTML img src attribute
			},

			markdown = {
				{ pattern = 'happy="(.-)"', placeholder = "@" }, -- classes in html
			},
		},
	},
}

-- autocmd({ "BufEnter", "BufWinEnter" }, {
-- 	pattern = { "*.html", "*.md" },
-- 	callback = function(_)
-- 		if not require("inline-fold.module").isHidden then
-- 			vim.cmd("InlineFoldToggle")
-- 		end
-- 	end,
-- })
