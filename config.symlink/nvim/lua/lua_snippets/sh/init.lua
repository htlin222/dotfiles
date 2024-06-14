local ls = require("luasnip")
local sn = ls.snippet_node
local d = ls.dynamic_node
local f = ls.function_node
local helpers = require("lua_snippets.helpers")
local switchIM = helpers.switchIM
local bash = helpers.bash
local current_time = helpers.current_time
local copy = helpers.copy
local date_input = helpers.date_input
local get_buffer_last_modified_time = helpers.get_buffer_last_modified_time
local i = ls.insert_node
local s = ls.snippet
local t = ls.text_node

return {
	-- ( &> /dev/null &)
	s(
		{ trig = "devnull", regTrig = false, priority = 100, snippetType = "autosnippet" },
		{ t("("), i(1), t("&> /dev/null &)"), i(0) }
	),
}
