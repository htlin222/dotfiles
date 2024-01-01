local ls = require("luasnip")
-- local helpers = require("custom.snippets.helpers")
-- some shorthands...
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("all", {
	s(":cancer:", { t("🦀 malignancy") }),
	s("...", { t({ "", ":::" }) }),
	s("hr ", { t({ "<hr>", "" }) }),
	s("br ", { t({ "<br>", "" }) }),
	s("---", { t({ "", "---", "", "" }), i(0), t({ "", "" }) }),
	s(":f", { t({ ":::free", "", "" }) }),
	s(":::f", { t({ ":::free", "", "" }) }),
	s("fff", { t({ ":::free", "", "" }) }),
	s("badge", { t({ '<img src="https://img.shields.io/badge/' }), i(0), t({ '-6c9a77"/>' }) }),
	s(":s", { t({ ":::split", "", "" }), i(0), t({ "", "", ":::", "" }) }),
	s("sss", { t({ ":::split", "", "" }), i(0), t({ "", "", ":::", "" }) }),
	s(":::c", { t({ ":::columns", "", "" }) }),
	s("ccc", { t({ ":::columns", "", "" }) }),
	s(":::d", { t({ ":::date", "", ":::" }) }),
	s("tts-", { t("texttospeech") }),
	s("cmp:", { t("🫠  Complication: ") }),
	s("def:", { t("📖 Defination: ") }),
	s("dx:", { t("🔎 Diagnosis: ") }),
	s("f/u", { t("follow-up") }),
	s("k:", { t("🍌potassium") }),
	s("mali", { t("malignancy") }),
	s("rx:", { t("treatment: ") }),
	s("pfx", { t('prefix: "'), i(0), t('"') }),
	s("desc.", { t('description: "'), i(0), t('"') }),
	s("adju", { t("adjuvant"), i(0) }),
	s("b9", { t("benign"), i(0) }),
	s("pt", { t("patient"), i(0) }),
	s("trail", { t("trial"), i(0) }),
	s("EtOH", { t("alcoholism"), i(0) }),
	s("utd", { t("uptodate"), i(0) }),
	s("___", { t("`___`"), i(0) }),
	s("_date", { t("`___`/`___`/`___`"), i(0) }),
	s("prelim", { t("preliminary"), i(0) }),
}, { type = "autosnippets", key = "all_auto" })
