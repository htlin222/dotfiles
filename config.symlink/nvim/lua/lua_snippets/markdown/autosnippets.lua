local ls = require "luasnip"
-- local helpers = require("custom.snippets.helpers")
-- some shorthands...
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local p = require("luasnip.extras").partial

ls.add_snippets("all", {
  s(":cancer:", { t "🦀 malignancy" }),
  s("hr ", { t { "", "<hr>", "" } }),
  s("br ", { t { "", "<br>", "" } }),
  s("---", { t { "", "---", "", "" }, i(0), t { "", "" } }),
  s("def:", { t "📖 Defination: " }),
  s("f/u", { t "follow-up" }),
  s("k:", { t "🍌potassium" }),
  s("mali", { t "malignancy" }),
  s("pd.", { t "progressive disease" }),
  s("rx", { t "treatment" }),
  s("r/r", { t "relapse and refractory" }),
  s("pfx", { t 'prefix: "', i(0), t '"' }),
  s("desc.", { t 'description: "', i(0), t '"' }),
  s(".incl", { t "{{ ", i(0), t " }}" }),
  s("b9", { t "benign", i(0) }),
  s("pt", { t "patient", i(0) }),
  s("trail", { t "trial", i(0) }),
  s("___", { t "`___`", i(0) }),
  s("prelim", { t "preliminary", i(0) }),
  s(".today", { t "- ", p(os.date, "%Y-%m-%d"), t ": " }),
  s("- today", { t "- ", p(os.date, "%Y-%m-%d"), t ": " }),
  s(".todo", { t "- [ ] ", p(os.date, "%Y-%m-%d"), t ": " }),
  s("- todo", { t "- [ ] ", p(os.date, "%Y-%m-%d"), t ": " }),
}, { type = "autosnippets", key = "all_auto" })
