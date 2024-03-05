local ls = require("luasnip")
local vim = vim
local i = ls.insert_node
local s = ls.snippet
local f = ls.function_node
-- local c = ls.choice_node
local t = ls.text_node
local helpers = require("custom.snippets.helpers")
local weather = helpers.weather
local playmp3 = helpers.playmp3
local date = helpers.date
-- local imgur = helpers.imgur
local fmta = require("luasnip.extras.fmt").fmta
local ret_filename = helpers.ret_filename
local previous = helpers.previous
local postfix = require("luasnip.extras.postfix").postfix
-- local types = require("luasnip.util.types")
-- local conds = require("luasnip.extras.conditions")
-- local conds_expand = require("luasnip.extras.conditions.expand")

return {
	s({ -- ①  table of snippet parameters:
		trig = ".weather",
		dscr = "show the weather",
	}, { -- ②  table of snippet nodes
		t("> 今天是 🗓️ "),
		f(date),
		t("，台北現在的天氣："),
		f(weather),
	}),
	s({ trig = "slug=" }, { f(function()
		vim.cmd("Slug")
	end) }),
	s({ trig = "as.slide" }, { t("[[~/Dropbox/slides/"), i(0), t("]]") }),
	s({ trig = "add.bib" }, { t("["), f(ret_filename), t(".bib]("), f(ret_filename), t(".bib)") }),
	-- f(ret_filename),
	s({ trig = "say" }, { f(playmp3) }),
	s({ trig = "ali " }, { f(function()
		vim.cmd("call Aliasing()")
	end) }),
	s(
		{ trig = ".yaml", dscr = "the front matter" },
		fmta(
			[[
      ---
      title: "<>"
      date: "<>"
      enableToc: false
      tags:
        - building
      ---

      <>
      <>
      <><><>

      # <>

      slug<>
      ]],
			{
				f(ret_filename),
				f(date),
				t("> [!info]"),
				t(">"),
				t("> 🌱 來自：[["),
				f(previous),
				t("]]"),
				f(ret_filename),
				i(0),
				-- f(playmp3),
			}
		)
	),
	-- postfix({ trig = ".ali", dscr = "aliasing" }, {
	-- 	f(function(_, parent)
	-- 		-- local cmd = "echo 'Hi there'"
	-- 		local ali = parent.snippet.env.POSTFIX_MATCH
	-- 		local cmd = "call AliasingNoPrompt('" .. ali .. "')"
	-- 		vim.cmd(cmd)
	-- 	end),
	-- 	-- i(i, "alias created"),
	-- }),
	postfix({ trig = ".pfx", dscr = "add prefix" }, {
		f(function(_, parent)
			-- local cmd = "echo 'Hi there'"
			local pfx = parent.snippet.env.POSTFIX_MATCH
			local cmd = "call AddPrefixNoPrompt('" .. pfx .. "')"
			vim.cmd(cmd)
		end),
		-- i(i, "alias created"),
	}),
}
