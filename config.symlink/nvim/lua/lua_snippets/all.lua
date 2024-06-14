local ls = require("luasnip")
-- local date = helpers.date
-- local fmt = require("luasnip.extras.fmt").fmt
-- local fmta = require("luasnip.extras.fmt").fmta
-- local t = ls.text_node
local sn = ls.snippet_node
local d = ls.dynamic_node
local f = ls.function_node
-- local postfix = require("luasnip.extras.postfix").postfix
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
	s("update", { t('date: "'), d(1, date_input, {}, { user_args = { "%Y-%m-%d" } }), t('"') }),
	s("pwd", f(bash, {}, { user_args = { "pwd" } })),
	s("update", { t('date: "'), d(1, date_input, {}, { user_args = { "%Y-%m-%d" } }), t('"') }),
	s("due", { t("<"), d(1, date_input, {}, { user_args = { "%Y-%m-%d" } }), t(">") }),
	s({ trig = ";;", regTrig = false, priority = 100, snippetType = "autosnippet" }, { f(switchIM) }),
	s({ trig = "pfx", snippetType = "autosnippet" }, { t('prefix: "'), i(0), t('"') }),
	s({ trig = "F=", regTrig = false, priority = 100, snippetType = "autosnippet" }, { t("T") }),
	s({ trig = "T=", regTrig = false, priority = 100, snippetType = "autosnippet" }, { t("F") }),
	s({ trig = "false=", regTrig = false, priority = 100, snippetType = "autosnippet" }, { t("true") }),
	s({ trig = "last_mod_stat" }, { t("'last modifed at "), f(get_buffer_last_modified_time), t("'") }),
	s({ trig = "now" }, { f(current_time), i(0) }),
	s({ trig = "true=", regTrig = false, priority = 100, snippetType = "autosnippet" }, { t("false") }),
	s({ trig = "space;", regTrig = false, priority = 100, snippetType = "autosnippet" }, { t("&nbsp;") }),
	s({ trig = "emoji;", regTrig = false, priority = 100, snippetType = "autosnippet" }, { t("&#"), i(0), t(";") }),
	s({ trig = "footnote", regTrig = false, priority = 100 }, { t("* † ‡ § ‖ ¶") }),
	s(
		{ trig = "kbd", regTrig = false, priority = 100, snippetType = "autosnippet" },
		{ t("<kbd>"), i(1), t("</kbd>"), i(0) }
	),
}
