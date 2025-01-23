local ls = require "luasnip"
-- some shorthands...
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
return {
  -- s({ trig = "free" }, { t("test") }),
  s({ trig = "more" }, { t { "<!--more-->" } }),
}
