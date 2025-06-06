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
  s(
    { trig = "2:1" },
    { t { "", ":::twoone", "", "" }, i(1), t { "", "", ":::split", "", "" }, i(0), t { "", "", ":::", "", "" } }
  ),
  s(
    { trig = "1:2" },
    { t { "", ":::onetwo", "", "" }, i(1), t { "", "", ":::split", "", "" }, i(0), t { "", "", ":::", "", "" } }
  ),
  s({ trig = "split" }, { t { "", ":::split", "", "" }, i(0) }),
  s({ trig = ":::" }, { t { "", "", ":::", "", "" }, i(0) }),
  s({ trig = "+++", desc = "Summary\nand\nDetail" }, { t { "+++" }, i(0), t { "", "", "+++" } }),
  s({ trig = "++", desc = "Insertion" }, { t { "++" }, i(0), t { "++" } }),
  s({ trig = "==", desc = "Mark" }, { t { "++" }, i(0), t { "++" } }),
  -- s({ trig = "ins" }, { t({ "<ins>" }), i(0), t({ "</ins>" })},
  -- s({ trig = "split" }, { t({ "", ":::split", "", "" }), i(0), t({ "", "", ":::", "" }) }),
  s({ trig = "even" }, { t { "", ":::columns", "", "" } }),
  s({ trig = "keypoints" }, { t { "", "<!-- _class: keypoints -->", "" } }),
  s({ trig = "bgr" }, { t { "bg right:" }, i(0), t { "0%" } }),
  s({ trig = "bgl" }, { t { "bg left:" }, i(0), t { "0%" } }),
  -- bg right:50%
  s({ trig = "shadow" }, { t { "drop-shadow:0px,45px,30px,rgba(0,0,0,.7) Figure: width:1150px" }, i(0) }),
  s({ trig = "opacity" }, { t { "bg opacity:.3 h:500px" }, i(0) }),
  s({ trig = "frag" }, { t { '{data-marpit-fragment="' }, i(0), t { '"}' } }),
  s({ trig = "fontsize" }, { t { '<div style="font-size: ' }, i(0), t { 'px">' } }),
  s({ trig = "flexlist" }, { t { '<div class="flex-list">', "" }, i(0), t { "</div>" } }),
  s({ trig = "div" }, { t { "<div>" } }),
  s({ trig = "/div" }, { t { "</div>" } }),
  s({ trig = "abs" }, {
    t { '<div style="position: absolute; left: 100px; top: 350px; font-size: 24px;">', "" },
    i(0),
    t { "", "</div>" },
  }),
  --
}
