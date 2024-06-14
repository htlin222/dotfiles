return {
	"hkupty/iron.nvim",
	ft = { "python", "sh", "r" },
	config = function(plugins, opts)
		local iron = require("iron.core")

		iron.setup({
			config = {
				-- Whether a repl should be discarded or not
				scratch_repl = true,
				-- Your repl definitions come here
				repl_definition = {
					python = {
						command = { "ptpython" },
					},
					r = {
						command = { "R" },
					},
					sh = {
						-- Can be a table or a function that
						-- returns a table (see below)
						command = { "zsh" },
					},
				},
				-- How the repl window will be displayed
				-- See below for more information
				repl_open_cmd = require("iron.view").right(60),
				-- repl_open_cmd = require("iron.view").bottom(10),
			},
			-- Iron doesn't set keymaps by default anymore.
			-- You can set them here or manually add keymaps to the functions in iron.core
			keymaps = {
				send_motion = "<space>rc",
				visual_send = "<leader><leader>",
				send_file = "<space>rf",
				send_line = "<leader><leader>",
				send_mark = "<space>rm",
				mark_motion = "<space>rmc",
				mark_visual = "<space>rmc",
				remove_mark = "<space>rmd",
				cr = "<leader>.",
				interrupt = "<space>r<space>",
				exit = "<space>rq",
				clear = "<space>rx",
			},
			-- If the highlight is on, you can change how it looks
			-- For the available options, check nvim_set_hl
			highlight = {
				italic = true,
			},
			ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
		})

		-- iron also has a list of commands, see :h iron-commands for all available commands
	end,
}
