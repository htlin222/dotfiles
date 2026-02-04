-- WezTerm configuration
---------------------------------------------------------------

local cfg_misc = {
	default_prog = { "/opt/homebrew/bin/tmux" },
	window_close_confirmation = "NeverPrompt",
	check_for_updates = false,

	-- Avoid unexpected config breakage and unusable terminal
	automatically_reload_config = true,

	-- Make sure word selection stops on most punctuations.
	--
	-- Note that dot (.) & slash (/) are allowed though for
	-- easy selection of (partial) paths.
	selection_word_boundary = " \t\n{}[]()\"'`,;:@│┃*…$",

	-- Do not hold on exit by default.
	-- Because the default 'CloseOnCleanExit' can be annoying when exiting with
	-- Ctrl-D and the last command exited with non-zero: the shell will exit
	-- with non-zero and the terminal would hang until the window is closed manually.
	-- exit_behavior = "Close", -- NOTE: this is now the default, remove?

	-- Disable all noises
	audible_bell = "Disabled",
}

-- Merge configs and return!
------------------------------------------

local mytable = require("lib/mystdlib").mytable
local full_config = mytable.merge_all(
	cfg_misc,
	require("cfg_appearance"),
	require("cfg_fonts"),
	require("cfg_keys"),
	require("cfg_mouse"),
	{} -- so the last table can have an ending comma for git diffs :)
)

return full_config
