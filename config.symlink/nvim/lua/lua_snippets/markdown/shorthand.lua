local ls = require("luasnip")
-- some shorthands...
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
	s("cont", { t("continue") }),
	s(".do", { t("- [ ]") }),
	s("at", { t("@ ") }),
	s("GP", { t("general practitioner") }),
	s("pm", { t("afternoon") }),
	s("pig", { t("pigtail catheter") }),
	s("eff", { t("effusion") }),
	s("moni", { t("monitor") }),
	s("admfor", { t("admitted for") }),
	s("ativan", { t("lorazepam 2mg IV stat") }),
	s("discom", { t("discomfort") }),
	s("com", { t("comfort") }),
	s("cftz", { t("ceftazidime 2g IV Q8H") }),
	s("qd", { t("once daily") }),
	s("dev", { t("developed") }),
	s("lab", { t("laboratory investigation") }),
	s("metic", { t("metastatic") }),
	s("aca", { t("academy") }),
	s("dexa", { t("dexamethasone") }),
	s("A+O", { t("alert and oriented") }),
	s("regi", { t("regimen") }),
	s("dur", { t("during") }),
	s("hosp", { t("hospitalization") }),
	s("cdiff", { t("Clostridium difficile toxin") }),
	s("cath", { t("catheter") }),
	s("admfor", { t("admitted for") }),
	s("ziba", { t("unplanned accidental extubation") }),
	s("yo", { i(1), t("-year-old ") }, i(0)),
	s("easy", { t("🟢") }),
	s("medium", { t("🌕") }),
	s("hard", { t("🔴") }),
	s("schema", { t("🌊") }),
}
