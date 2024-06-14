local ls = require("luasnip")
local i = ls.insert_node
local s = ls.snippet
local t = ls.text_node
local f = ls.function_node
local d = ls.dynamic_node
local rep = require("luasnip.extras").rep
local fmta = require("luasnip.extras.fmt").fmta
local helpers = require("lua_snippets.helpers")
local ret_filename = helpers.ret_filename
local get_visual = helpers.get_visual
local postfix = require("luasnip.extras.postfix").postfix
local previous = helpers.previous
local alias = helpers.alias

return {
	postfix({ trig = ".month", dscr = "creat month emoji" }, {
		f(function(_, parent)
			local month = parent.snippet.env.POSTFIX_MATCH
			local command_template = [[
        sh ~/.dotfiles/shellscripts/emojimonth.sh "%s"
      ]]
			local emojimonth = string.format(command_template, month)
			local handle = io.popen(emojimonth)
			local result = handle:read("*a")
			handle:close()
			result = result:gsub("\n$", "") -- WARN: to avoid error
			print(result)
			return result .. " " .. month .. " months"
		end, {}),
	}),
	postfix({ trig = ".bar", dscr = "create progress" }, {
		f(function(_, parent)
			local input = parent.snippet.env.POSTFIX_MATCH
			-- TODO: ___ Change Script name here
			local command_template = [[
        sh ~/.dotfiles/shellscripts/emojibyten.sh "%s"
      ]]
			local emojimonth = string.format(command_template, input)
			local handle = io.popen(emojimonth)
			local result = handle:read("*a")
			handle:close()
			result = result:gsub("\n$", "") -- WARN: to avoid error
			print(result)
			return result
		end, {}),
	}),
	s(".op", { t("🈹") }),
	s(".ae", { t("🍄") }),
	s(".pfs", { t("🈚️") }),
	s(".efs", { t("🆓") }),
	s(".os", { t("✳️ ") }),
	s(".xrt", { t("☢️ ") }),
}
