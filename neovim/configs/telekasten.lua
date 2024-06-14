local vim = vim
local function determine_home()
	local current_file_path = vim.fn.expand("%:p")
	local inbox_path = vim.fn.expand("~/Dropbox/inbox")
	local medical_path = vim.fn.expand("~/Dropbox/Medical")
	if string.sub(current_file_path, 1, string.len(inbox_path)) == inbox_path then
		return inbox_path
	else
		return medical_path
	end
end
return { --telekasten
	"renerocksai/telekasten.nvim",
	-- event = { "BufReadPre " .. vim.fn.expand("~") .. "/Dropbox/Medical/**.md" },
	-- ft = { "markdown" },
	ft = { "markdown", "quarto" },
	dependencies = { "nvim-telescope/telescope.nvim" },
	config = function()
		vim.keymap.set("n", "<leader>z", "<cmd>Telekasten panel<CR>")
		vim.keymap.set("n", "<leader>zf", "<cmd>Telekasten find_notes<CR>")
		vim.keymap.set("n", "<leader>zg", "<cmd>Telekasten search_notes<CR>")
		vim.keymap.set("n", "<leader>zd", "<cmd>Telekasten goto_today<CR>")
		-- vim.keymap.set("n", "<leader>zz", "<cmd>Telekasten follow_link<CR>")
		vim.keymap.set("n", "<leader>zn", "<cmd>Telekasten new_note<CR>")
		vim.keymap.set("n", "<leader>zc", "<cmd>Telekasten show_calendar<CR>")
		vim.keymap.set("n", "<leader>zb", "<cmd>Telekasten show_backlinks<CR>")
		vim.keymap.set("n", "<leader>zI", "<cmd>Telekasten insert_img_link<CR>")
		-- Call insert link automatically when we start typing a link
		vim.keymap.set("i", "[[", "<cmd>Telekasten insert_link<CR>")
		-- q.v. treesitter README : Adding parsers
		vim.treesitter.language.register("markdown", "telekasten")
		vim.opt.foldlevel = 3
		require("core.utils").load_mappings("telekasten")
		require("telekasten").setup({
			subdirs_in_links = false,
			-- home = vim.fn.expand("~/Dropbox/inbox"), -- Put the name of your notes directory here
			-- home = vim.fn.expand("~/Dropbox/Medical"), -- Put the name of your notes directory here
			home = determine_home(),
			auto_set_filetype = false,
			tag_notation = "yaml-bare",
			template_new_note = vim.fn.expand("~/Dropbox/Medical/template/new_note.md"),
			template_new_daily = vim.fn.expand("~/Dropbox/Medical/template/new_daily.md"),
			template_new_weekly = vim.fn.expand("~/Dropbox/Medical/template/new_weekly.md"),
		})
	end,
}
