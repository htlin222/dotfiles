local ls = require("luasnip")
local f = ls.function_node
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local postfix = require("luasnip.extras.postfix").postfix
local c = ls.choice_node
local helpers = require("custom.snippets.helpers")
-- local get_visual = helpers.get_visual
-- local sn = ls.snippet_node
-- local f = ls.function_node
-- local d = ls.dynamic_node
-- local r = ls.restore_node
return {
	s({
		trig = "ha",
		dscr = "cited from\nHarrison's \nPrinciples of \nInternal Medicine, 21e",
	}, {
		t("von [[Harrisons]] 📚 21e: "),
		c(1, {
			t("FIGURE"),
			t("TABLE"),
			t("Chapter"),
		}),
		t(" "),
		i(2, "123-456"),
	}),
	s({ trig = "forbib", dscr = "DOI to AMA" }, {
		f(function() end),
	}),
}
