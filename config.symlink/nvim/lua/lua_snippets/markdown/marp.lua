local ls = require "luasnip"
-- some shorthands...
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
return {
  -- s({ trig = "free" }, { t("test") }),
  s(
    { trig = "free" },
    { t { ":::free", "", "" }, i(1), t { "", "", ":::split", "", "" }, i(0), t { "", "", ":::", "", "" } }
  ),
  s(
    { trig = "half" },
    { t { "", ":::half", "", "" }, i(1), t { "", "", ":::split", "", "" }, i(0), t { "", "", ":::", "", "" } }
  ),
  s({ trig = "split" }, { t { "", ":::split", "", "" }, i(0) }),
  s({ trig = ":::" }, { t { "", "", ":::", "", "" }, i(0) }),
  s({ trig = "+++", desc = "Summary\nand\nDetail" }, { t { "+++" }, i(0), t { "", "", "+++" } }),
  s({ trig = "++", desc = "Insertion" }, { t { "++" }, i(0), t { "++" } }),
  s({ trig = "==", desc = "Mark" }, { t { "++" }, i(0), t { "++" } }),
  -- s({ trig = "ins" }, { t({ "<ins>" }), i(0), t({ "</ins>" })},
  -- s({ trig = "split" }, { t({ "", ":::split", "", "" }), i(0), t({ "", "", ":::", "" }) }),
  s({ trig = "even" }, { t { "", ":::columns", "", "" } }),
  s({ trig = "bgrt" }, { t { "bg right:50%" } }),
  -- bg right:50%
  s({ trig = "shadow" }, { t { "drop-shadow:0px,45px,30px,rgba(0,0,0,.7) Figure: width:1150px" }, i(0) }),
  s({ trig = "opacity" }, { t { "bg opacity:.3 h:500px" }, i(0) }),
}
