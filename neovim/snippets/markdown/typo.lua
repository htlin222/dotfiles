local ls = require("luasnip")
-- some shorthands...
local s = ls.snippet
local t = ls.text_node
return {
	s({ trig = "dx:", snippetType = "autosnippet" }, { t("test") }),
	s({ trig = "c(%d+)", regTrig = true }, {
		t("will only expand for even numbers"),
	}, {
		condition = function(line_to_cursor, matched_trigger, captures)
			return tonumber(captures[1]) % 2 == 0
		end,
	}),
}
