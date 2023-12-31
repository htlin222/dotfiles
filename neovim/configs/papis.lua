return {
	"jghauser/papis.nvim",
	dependencies = {
		"kkharji/sqlite.lua",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("papis").setup({
			-- Your configuration goes here
			-- List of enabled papis.nvim modules.
			enable_modules = {
				["search"] = true, -- Enables/disables the search module
				["completion"] = true, -- Enables/disables the completion module
				["cursor-actions"] = true, -- Enables/disables the cursor-actions module
				["formatter"] = true, -- Enables/disables the formatter module
				["colors"] = true, -- Enables/disables default highlight groups (you
				-- probably want this)
				["base"] = true, -- Enables/disables the base module (you definitely
				-- want this)
				["debug"] = false, -- Enables/disables the debug module (useful to
				-- troubleshoot and diagnose issues)
			},

			-- Defines citation formats for various filetypes. When the value is a table, then
			-- the first entry is used to insert citations, whereas the second will be used to
			-- find references (e.g. by the `cursor-action` module). `%s` stands for the reference.
			-- Note that the first entry is a string (where e.g. `\` needs to be excaped as `\\`)
			-- and the second a lua pattern (where magic characters need to be escaped with
			-- `%`; https://www.lua.org/pil/20.2.html).
			cite_formats = {
				tex = { "\\cite{%s}", "\\cite[tp]?%*?{%s}" },
				markdown = "@%s",
				rmd = "@%s",
				plain = "%s",
				org = { "[cite:@%s]", "%[cite:@%s]" },
				norg = "{= %s}",
			},

			-- What citation format to use when none is defined for the current filetype.
			cite_formats_fallback = "plain",

			-- Enable default keymaps.
			enable_keymaps = false,

			-- Enable commands (disabling this still allows you to call the relevant lua
			-- functions directly)
			enable_commands = true,

			-- Whether to enable the file system event watcher. When disabled, the database
			-- is only updated on startup.
			enable_fs_watcher = true,

			-- The sqlite schema of the main `data` table. Only the "text" and "luatable"
			-- types are allowed.
			data_tbl_schema = {
				id = { "integer", pk = true },
				papis_id = { "text", required = true, unique = true },
				ref = { "text", required = true, unique = true },
				author = "text",
				editor = "text",
				year = "text",
				title = "text",
				type = "text",
				abstract = "text",
				time_added = "text",
				notes = "luatable",
				journal = "text",
				author_list = "luatable",
				tags = "luatable",
				files = "luatable",
			},

			-- Path to the papis.nvim database.
			db_path = vim.fn.stdpath("data") .. "/papis_db/papis-nvim.sqlite3",

			-- Name of the `yq` executable.
			yq_bin = "yq",

			-- The papis options relevant for papis.nvim (see above minimal config). By
			-- default it is unset, which prompts papis.nvim to call `papis config` to
			-- get the values.
			papis_python = nil,

			-- Function to execute when adding a new note. `ref` is the citation key of the
			-- relevant entry and `notes_name` is defined in `papis_python` above.
			create_new_note_fn = function(papis_id, notes_name)
				vim.fn.system(
					string.format(
						"papis update --set notes %s papis_id:%s",
						vim.fn.shellescape(notes_name),
						vim.fn.shellescape(papis_id)
					)
				)
			end,

			-- Filename patterns that trigger papis.nvim to start. `%info_name%` needs to be
			-- first item; it is replaced with `info_name` as defined in `papis_python`.
			init_filenames = { "%info_name%", "*.md", "*.norg" },

			-- Configuration of the search module.
			["search"] = {

				-- Wether to enable line wrap in the telescope previewer.
				wrap = true,

				-- What keys to search for matches.
				search_keys = { "author", "editor", "year", "title", "tags" },

				-- The format for the previewer. Each line in the config represents a line in
				-- the preview. For each line, we define:
				--   1. The key whose value is shown
				--   2. How it is formatted (here, each is just given as is)
				--   3. The highlight group
				--   4. (Optionally), `show_key` causes the key's name to be displayed in addition
				--      to the value. When used, there are then another two items defining the
				--      formatting of the key and its highlight group. The key is shown *before*
				--      the value in the preview (even though it is defined after it in this
				--      configuration (e.g. `title = Critique of Pure Reason`)).
				-- `empty_line` is used to insert an empty line
				preview_format = {
					{ "author", "%s", "PapisPreviewAuthor" },
					{ "year", "%s", "PapisPreviewYear" },
					{ "title", "%s", "PapisPreviewTitle" },
					{ "empty_line" },
					{ "ref", "%s", "PapisPreviewValue", "show_key", "%s = ", "PapisPreviewKey" },
					{ "type", "%s", "PapisPreviewValue", "show_key", "%s = ", "PapisPreviewKey" },
					{ "tags", "%s", "PapisPreviewValue", "show_key", "%s = ", "PapisPreviewKey" },
					{ "files", "%s", "PapisPreviewValue", "show_key", "%s = ", "PapisPreviewKey" },
					{ "notes", "%s", "PapisPreviewValue", "show_key", "%s = ", "PapisPreviewKey" },
					{ "journal", "%s", "PapisPreviewValue", "show_key", "%s = ", "PapisPreviewKey" },
					{ "abstract", "%s", "PapisPreviewValue", "show_key", "%s = ", "PapisPreviewKey" },
				},

				-- The format of each line in the the results window. Here, everything is show on
				-- one line (otherwise equivalent to points 1-3 of `preview_format`).
				results_format = {
					{ "author", "%s ", "PapisResultsAuthor" },
					{ "year", "(%s) ", "PapisResultsYear" },
					{ "title", "%s", "PapisResultsTitle" },
				},
			},

			-- Configuration of the cursor-actions module.
			["cursor-actions"] = {

				-- The format of the popup shown on `:PapisShowPopup` (equivalent to points 1-3
				-- of `preview_format`)
				popup_format = {
					{ "author", "%s", "PapisPopupAuthor" },
					{ "year", "%s", "PapisPopupYear" },
					{ "title", "%s", "PapisPopupTitle" },
				},
			},

			-- Configuration of formatter module.
			["formatter"] = {

				-- This function runs when first opening a new note. The `entry` arg is a table
				-- containing all the information about the entry (see above `data_tbl_schema`).
				-- This example is meant to be used with the `.norg` filetype.
				format_notes_fn = function(entry)
					-- Some string formatting templates (see above `results_format` option for
					-- more details)
					local title_format = {
						{ "author", "%s ", "" },
						{ "year", "(%s) ", "" },
						{ "title", "%s", "" },
					}
					-- Format the strings with information in the entry
					local title = require("papis.utils"):format_display_strings(entry, title_format)
					-- Grab only the strings (and disregard highlight groups)
					for k, v in ipairs(title) do
						title[k] = v[1]
					end
					-- Define all the lines to be inserted
					local lines = {
						"@document.meta",
						"title: " .. table.concat(title),
						"description: ",
						"categories: [",
						"  notes",
						"  academia",
						"  readings",
						"]",
						"created: " .. os.date("%Y-%m-%d"),
						"version: " .. require("neorg.config").version,
						"@end",
						"",
					}
					-- Insert the lines
					vim.api.nvim_buf_set_lines(0, 0, #lines, false, lines)
					-- Move cursor to the bottom
					vim.cmd("normal G")
				end,
			},

			-- Configurations relevant for parsing `info.yaml` files.
			["papis-storage"] = {

				-- As lua doesn't deal well with '-', we define conversions between the format
				-- in the `info.yaml` and the format in papis.nvim's internal database.
				key_name_conversions = {
					time_added = "time-added",
				},

				-- The format used for tags. Will be determined automatically if left empty.
				-- Can be set to `tbl` (if a lua table), `,` (if comma-separated), `:` (if
				-- semi-colon separated), ` ` (if space separated).
				tag_format = nil,

				-- The keys which `.yaml` files are expected to always define. Files that are
				-- missing these keys will cause an error message and will not be added to
				-- the database.
				required_keys = { "papis_id", "ref" },
			},

			-- Configuration of logging.
			log = {

				-- What levels to log (`off` to disable). Debug mode is more conveniently
				-- enabled in `enable_modules`.
				level = "off",

				-- How to format log strings.
				notify_format = "%s",
			},
		})
	end,
}
