return {
	"mzlogin/vim-markdown-toc",
	ft = { "markdown", "md" },
	event = "VeryLazy",
	config = function()
		vim.g.vmt_max_level = 2
		vim.g.vmt_list_item_char = "-"
		vim.g.vmt_fence_text = '_header: "Outline"'
		vim.g.vmt_fence_closing_text = '_footer: ""'
		vim.g.vmt_fence_hidden_markdown_style = "GFM"
	end,
}
