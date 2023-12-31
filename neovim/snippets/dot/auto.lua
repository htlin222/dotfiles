local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("all", {
	s("//___", { t("// ___"), i(0) }),
	s("theblue", { t("#2d696a"), i(0) }),
	s("thegreen", { t("#6c9a77"), i(0) }),
}, { type = "autosnippets", key = "all_auto" })
