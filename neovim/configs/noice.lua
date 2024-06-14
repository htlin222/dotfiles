return {
	"folke/noice.nvim",
	event = "VeryLazy",
	opts = {
		-- add any options here
	},
	dependencies = {
		-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
		"MunifTanjim/nui.nvim",
		-- OPTIONAL:
		--   `nvim-notify` is only needed, if you want to use the notification view.
		--   If not available, we use `mini` as the fallback
		-- "rcarriga/nvim-notify",
		"hrsh7th/cmp-cmdline",
	},
	config = function()
		require("cmp").setup.cmdline(":", {
			mapping = require("cmp").mapping.preset.cmdline(),
			sources = require("cmp").config.sources({
				{ name = "path" },
			}, {
				{
					name = "cmdline",
					option = {
						ignore_cmds = { "Man", "!" },
					},
				},
			}),
		})
		require("noice").setup({
			views = {
				cmdline_popup = {
					border = {
						style = "none",
						padding = { 2, 3 },
					},
					filter_options = {},
					win_options = {
						winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
					},
				},
			},
			lsp = {
				progress = {
					enabled = true,
					-- Lsp Progress is formatted using the builtins for lsp_progress. See config.format.builtin
					-- See the section on formatting for more details on how to customize.
					format = "lsp_progress",
					format_done = "lsp_progress_done",
					throttle = 1000 / 30, -- frequency to update lsp progress message
					view = "mini",
				},
				override = {
					-- override the default lsp markdown formatter with Noice
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					-- override the lsp markdown formatter with Noice
					["vim.lsp.util.stylize_markdown"] = true,
					-- override cmp documentation with Noice (needs the other options to work)
					["cmp.entry.get_documentation"] = true,
				},
				hover = {
					enabled = true,
					silent = true, -- set to true to not show a message if hover is not available
					view = nil, -- when nil, use defaults from documentation
					opts = {}, -- merged with defaults from documentation
				},
				signature = {
					-- enabled = true, TODO: how to avoid double signature window
					enabled = true,
					auto_open = {
						enabled = true,
						trigger = true, -- Automatically show signature help when typing a trigger character from the LSP
						luasnip = true, -- Will open signature help when jumping to Luasnip insert nodes
						throttle = 50, -- Debounce lsp signature help request by 50ms
					},
					view = nil, -- when nil, use defaults from documentation
					opts = {}, -- merged with defaults from documentation
				},
				message = {
					enabled = true,
					view = "mini",
					opts = {},
				},
				-- defaults for hover and signature help
				documentation = {
					view = "hover",
					opts = {
						lang = "markdown",
						replace = true,
						-- render = "markdown",
						-- render = "html",
						render = "plain",
						format = { "💡\n\n{message}" },
						win_options = { concealcursor = "n", conceallevel = 3 },
					},
				},
			},
			cmdline = {
				enabled = true, -- enables the Noice cmdline UI
				view = "cmdline_popup", -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom
				opts = {}, -- global options for the cmdline. See section on views
				format = {
					-- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
					-- view: (default is cmdline view)
					-- opts: any options passed to the view
					-- icon_hl_group: optional hl_group for the icon
					title = { " " }, -- set to anything or empty string to hide
					cmdline = { pattern = "^:", icon = "", lang = "vim" },
					search_down = {
						-- kind = "search",
						pattern = "^/",
						icon = " ",
						lang = "regex",
						view = "cmdline",
					},
					search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
					filter = { pattern = "^:%s*!", icon = " ", lang = "bash" },
					lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
					help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
					echo = { pattern = "^:%s*ec?h?o?%s+", icon = "󰓃" },
					verbose = { pattern = "^:%s*ver?b?o?s?e?%s+", icon = "󰏶" },
					input = {}, -- Used by input()
					-- lua = false, -- to disable a format, set to `false`
				},
			}, -- you can enable a preset for easier configuration
			messages = {
				enabled = true,
				view_search = "mini",
			},
			notify = {
				enabled = true,
				view_search = "mini",
			},
			presets = {
				bottom_search = true, -- use a classic bottom cmdline for search
				command_palette = true, -- position the cmdline and popupmenu together
				long_message_to_split = true, -- long messages will be sent to a split
				inc_rename = true, -- enables an input dialog for inc-rename.nvim
				lsp_doc_border = true, -- add a border to hover docs and signature help
			},
			routes = {
				{
					filter = {
						event = "msg_show",
						kind = "",
						find = "已寫入",
					},
					opts = { skip = true },
				},
				{
					filter = {
						event = "msg_show",
						kind = "",
						find = "code_action",
					},
					opts = { skip = true },
				},
				{
					view = "notify",
					filter = { event = "msg_showmode" },
				},
			},
			popupmenu = {
				enabled = true, -- enables the Noice popupmenu UI
				---@type 'nui'|'cmp'
				backend = "cmp", -- backend to use to show regular cmdline completions
				-- Icons for completion item kinds (see defaults at noice.config.icons.kinds)
				kind_icons = {}, -- set to `false` to disable icons
			},
			markdown = {
				hover = {
					["|(%S-)|"] = vim.cmd.help, -- vim help links
					["%[.-%]%((%S-)%)"] = require("noice.util").open, -- markdown links
					["%[%[%S-%]%]"] = require("noice.util").open, -- markdown links
				},
				highlights = {
					["|%S-|"] = "@text.reference",
					["@%S+"] = "@parameter",
					["^%s*(Parameters:)"] = "@text.title",
					["^%s*(Return:)"] = "@text.title",
					["^%s*(See also:)"] = "@text.title",
					["{%S-}"] = "@parameter",
					["^#.*"] = "@text.title",
				},
			},
		})
	end,
}
-- https://github.com/TechnicalDC/NvConf/blob/main/lua/plugins/ui.lua
