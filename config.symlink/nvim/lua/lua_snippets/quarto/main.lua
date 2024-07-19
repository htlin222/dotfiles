local ls = require "luasnip"
-- some shorthands...
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
return {
  s({ trig = "inc" }, { t { "::: {.incremental}", "", "" }, i(0), t { "", "", ":::", "", "" } }),
  s({ trig = "stack" }, { t { '{data-stack-name="' }, i(0), t { '"}' } }),
  s({ trig = "small" }, { i(0), t { "{.smaller}" } }),
  s({ trig = "fit" }, { i(0), t { "{.r-fit-text}" } }),
  s({ trig = "scroll" }, { i(0), t { "{.scrollable}" } }),
  s({ trig = "v-center" }, { i(0), t { ".v-center-container" } }),
  s({ trig = "br" }, { t { "<br>" } }),
  s({ trig = "hr" }, { t { "<hr>" } }),
  s({ trig = "col" }, {
    t { "<!-- 👉👉👉👉👉👉 Two Columns -->", ":::: {.columns}", "::: {.column width='50%'}", "", "" },
    i(1),
    t { "", "", ":::", "::: {.column width='50%'}", "", "" },
    i(0),
    t { "", "", ":::", "::::", "<!-- 👉👉👉👉👉 End of Two Columns -->" },
  }),
  s({ trig = "note" }, {
    t { "", "::: {.notes}", "", "" },
    i(0),
    t { "", "", ":::" },
  }),
  s({ trig = "fit" }, {
    t { "", "::: {.r-fit-text}", "", "" },
    i(0),
    t { "", "", ":::" },
  }),
  s({ trig = "center" }, {
    t { "", "::: {.center}", "", "" },
    i(0),
    t { "", "", ":::" },
  }),
  s({ trig = "cite" }, { t { "^[" }, i(0), t { "]" } }),
  s({ trig = "tab" }, {
    t { "::: {.panel-tabset}", "", "", "### " },
    i(1),
    t { "", "", "### " },
    i(0),
    t { "", "", ":::" },
  }),
  s({ trig = "abs" }, {
    t { '{.absolute top="' },
    i(1),
    t { '" left="' },
    i(2),
    t { '" width="' },
    i(3),
    t { '" height="' },
    i(0),
    t { '"}' },
  }),
}
