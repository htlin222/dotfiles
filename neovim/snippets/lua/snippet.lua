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
	s({
		trig = "text",
		dscr = "des",
	}, {
		t("text here"),
	}),
	s(
		{ trig = "n.s", dscr = "new snippet here" },
		fmta(
			[[
      s({ -- ①  table of snippet parameters:
        trig = '<>',
        dscr = '<>',
        regTrig = false,
        -- ②  Do you want autosnippet?
        <>
      },{ -- ②  table of snippet nodes
        <>,
      }),<>
      ]],
			{
				i(1, "trigger"),
				i(2, "description"),
				c(3, {
					t(""),
					t("snippetType = 'autosnippet',"),
				}),
				c(4, {
					t("i('wow')"),
					t("t('Hi there')"),
				}),
				i(0),
			}
		)
	),
}
