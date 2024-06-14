local ls = require("luasnip")
local i = ls.insert_node
local s = ls.snippet
local t = ls.text_node
-- local f = ls.function_node
-- local d = ls.dynamic_node
-- local rep = require("luasnip.extras").rep
-- local fmta = require("luasnip.extras.fmt").fmta
-- local ret_filename = helpers.ret_filename
-- local get_visual = helpers.get_visual
-- local postfix = require("luasnip.extras.postfix").postfix
-- local previous = helpers.previous
-- local alias = helpers.alias

return {
	s("fill", { t('style="filled",'), i(0) }),
	s("w=", { t("width=1"), i(0), t({ "," }) }),
	s("p=", { t("penwidth=1"), i(0), t({ "," }) }),
	s("rd=", { t('rankdir="LR'), i(0), t({ '",' }) }),
	s("rank", { t("{rank=same; "), i(0), t({ "}" }) }),
	s(".op", { t("🈹") }),
	s(".ae", { t("🍄") }),
	s(".pfs", { t("🈚️") }),
	s(".efs", { t("🆓") }),
	s(".os", { t("✳️ ") }),
	s(".xrt", { t("☢️ ") }),
	s({ trig = "   ", dscr = "a space", wordTrig = false, snippetType = "autosnippet" }, {
		t({ " &nbsp; " }),
	}),
}
