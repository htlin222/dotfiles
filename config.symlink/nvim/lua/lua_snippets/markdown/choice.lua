local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
-- local helpers = require("custom.snippets.helpers")
-- local sn = ls.snippet_node
-- local f = ls.function_node
-- local d = ls.dynamic_node
-- local r = ls.restore_node
return {
	s({ trig = "sub", dscr = "選擇不同次專科\n用<c-j>/<c-k>來切換" }, {
		t("- "),
		c(1, {
			t("[[cardiology]] 🫀 "),
			t("[[pulmonology]] 🫁 "),
			t("[[gastroenterology]] 🍚"),
			t("[[nephrology]] 💧"),
			t("[[hematology]] 🩸"),
			t("[[oncology]] 🦀"),
			t("[[infectious disease]] 🦠"),
			t("[[endocrinology]] 🐼"),
			t("[[rheumatology]] 🤡"),
		}),
		i(2),
	}),
	s("tag", {
		t("  - "),
		c(1, {
			t("build"),
			t("done"),
			t("blog"),
		}),
		i(2),
	}),
	s({ trig = ".ii", snippetType = "autosnippet" }, { t("${1:"), i(0), t("}") }),
}
