local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local fmta = require("luasnip.extras.fmt").fmta
-- local sn = ls.snippet_node
-- local f = ls.function_node
-- local d = ls.dynamic_node
-- local r = ls.restore_node

return {
	s({ trig = "--", dscr = "des", snippetType = "autosnippet" }, { t(" <- ") }),
	s({ trig = ">>", dscr = "des", snippetType = "autosnippet" }, { t(" %>% ") }),
}
