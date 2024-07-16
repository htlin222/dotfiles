local ls = require "luasnip"
-- some shorthands...
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
-- callout-appearance: simple
-- callout-icon: false
return {
  s({ trig = "callout-note" }, {
    t { "", '::: {.callout-note collapse="false"}', "" },
    i(0),
    t { "", ":::" },
  }),
  s({ trig = "callout-tip" }, {
    t { "", '::: {.callout-tip, collapse="false"}', "" },
    i(0),
    t { "", ":::" },
  }),
  s({ trig = "callout-warning" }, {
    t { "", '::: {.callout-warning collapse="false"}', "" },
    i(0),
    t { "", ":::" },
  }),
  s({ trig = "callout-caution" }, {
    t { "", '::: {.callout-caution collapse="false"}', "" },
    i(0),
    t { "", ":::" },
  }),
  s({ trig = "callout-important" }, {
    t { "", '::: {.callout-important collapse="false"}', "" },
    i(0),
    t { "", ":::" },
  }),
  s({ trig = "calltitle" }, { t { 'title="' } }, i(0), t { '"' }),
}
