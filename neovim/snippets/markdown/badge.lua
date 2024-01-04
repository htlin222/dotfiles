local ls = require("luasnip")
local extras = require("luasnip.extras")
local l = extras.l
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local matches = require("luasnip.extras.postfix").matches
local postfix = require("luasnip.extras.postfix").postfix
local clinical_trial_API =
	"https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fclinicaltrials.gov%2Fapi%2Fv2%2Fstudies%2F"
local clinical_trial_API_field = "%3Fformat%3Djson%26fields%3"

return {
	s("badge", { t({ "![badge](https://img.shields.io/badge/" }), i(0), t({ "-6c9a77)" }) }),
	postfix({ trig = ":all.badge", matches.line }, {
		l(
			l.POSTFIX_MATCH
				.. ".phase "
				.. l.POSTFIX_MATCH
				.. ".allocation "
				.. l.POSTFIX_MATCH
				.. ".mask "
				.. l.POSTFIX_MATCH
				.. ".id "
		),
	}),
	postfix({ trig = ".id=", matches.line, snippetType = "autosnippet" }, {
		l(
			"!["
				.. l.POSTFIX_MATCH
				.. " badge:NCTId]("
				.. clinical_trial_API
				.. l.POSTFIX_MATCH
				.. "%3Fformat%3Djson%26fields%3DNCTId&query=protocolSection.identificationModule.nctId&label=NCTId&color=6c9a77)"
		),
	}),
	postfix({ trig = ".phase=", matches.line, snippetType = "autosnippet" }, {
		l(
			"!["
				.. l.POSTFIX_MATCH
				.. " badge:phase]("
				.. clinical_trial_API
				.. l.POSTFIX_MATCH
				.. "%3Fformat%3Djson%26fields%3DPhase&query=protocolSection.designModule.phases&label=Phase&color=6c9a77)"
		),
	}),
	postfix({ trig = ".allocation=", matches.line, snippetType = "autosnippet" }, {
		l(
			"!["
				.. l.POSTFIX_MATCH
				.. " badge:Allocation]("
				.. clinical_trial_API
				.. l.POSTFIX_MATCH
				.. "%3Fformat%3Djson%26fields%3DDesignAllocation&query=protocolSection.designModule.designInfo.allocation&label=Allocation&color=6c9a77)"
		),
	}),
	postfix({ trig = ".mask=", matches.line, snippetType = "autosnippet" }, {
		l(
			"!["
				.. l.POSTFIX_MATCH
				.. " badge:mask]("
				.. clinical_trial_API
				.. l.POSTFIX_MATCH
				.. clinical_trial_API_field
				.. "DesignMasking"
				.. "&query=" -- from JSON path
				.. "protocolSection.designModule.designInfo.maskingInfo.masking"
				.. " &label=" -- Label for the badge left side
				.. "Masking"
				.. "&color=6c9a77)"
		),
	}),
}
