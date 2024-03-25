local ls = require("luasnip")
-- some shorthands...
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
return {
	-- s({ trig = "free" }, { t("test") }),
	s(
		{ trig = "free" },
		{ t({ ":::free", "", "" }), i(1), t({ "", "", ":::split", "", "" }), i(0), t({ "", "", ":::", "", "" }) }
	),
	s(
		{ trig = "half" },
		{ t({ "", ":::half", "", "" }), i(1), t({ "", "", ":::split", "", "" }), i(0), t({ "", "", ":::", "", "" }) }
	),
	s({ trig = "split" }, { t({ "", ":::split", "", "" }), i(0), t({ "", "", ":::", "" }) }),
	s({ trig = "even" }, { t({ "", ":::columns", "", "" }) }),
	s({ trig = "date" }, { t({ "", ":::date", "" }) }),
	-- s({ trig = "h4" }, { t({ "#### " }), i(0) }),
}
