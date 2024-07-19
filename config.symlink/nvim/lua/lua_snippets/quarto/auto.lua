local ls = require "luasnip"
-- local helpers = require("custom.snippets.helpers")
-- some shorthands...
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local p = require("luasnip.extras").partial

ls.add_snippets("all", {
  s("hr ", { t { "", "<hr>", "" } }),
  s("br ", { t { "", "<br>", "" } }),
  s("---", { t { "", "---", "", "" }, i(0), t { "", "" } }),
  s("box", { t { "```{" }, i(0), t { "}", "# YOUR CODE HERE", "```", "" } }),
  s("...", { t { "", ". . .", "", "" }, i(0), t { "", "" } }),
  s(".today", { t "- ", p(os.date, "%Y-%m-%d"), t ": " }),
  s("- today", { t "- ", p(os.date, "%Y-%m-%d"), t ": " }),
  s(".todo", { t "- [ ] ", p(os.date, "%Y-%m-%d"), t ": " }),
  s("- todo", { t "- [ ] ", p(os.date, "%Y-%m-%d"), t ": " }),
}, { type = "autosnippets", key = "all_auto" })
