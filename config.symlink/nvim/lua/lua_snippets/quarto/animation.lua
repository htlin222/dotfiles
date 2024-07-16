local ls = require "luasnip"
-- some shorthands...
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
return {
  s({ trig = "frag" }, {
    t { "", "::: {.fragment}", "" },
    i(0),
    t { "", ":::" },
  }),
  s({ trig = "hlgreen" }, {
    t { "", "::: {.fragment .highlight-green}", "" },
    i(0),
    t { "", ":::" },
  }),
}
