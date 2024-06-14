local ls = require("luasnip")
local t = ls.text_node
local f = ls.function_node
local postfix = require("luasnip.extras.postfix").postfix

local function generate_command(graphviz_template, newgv)
	local command_template = [[
    mkdir -p "src"; cat ~/Dropbox/graph/%s.gv > "./src/%s.gv"; dot -Tsvg "./src/%s.gv" -o "./src/%s.svg" -q
]]

	local touch_newgv = string.format(command_template, graphviz_template, newgv, newgv, newgv)
	return touch_newgv
end

local function image_link_format(filename)
	return "![height:450px title: " .. filename .. "](./src/" .. filename .. ".svg)"
end

local function graphviz_link_format(filename)
	print("圖已生🥰")
	return "> [" .. filename .. " Ⓒ Hsieh-Ting Lin](./src/" .. filename .. ".gv)"
end

return {
	postfix({ trig = ".basic.svg", dscr = "creat a two arm svg", snippetType = "autosnippet" }, {
		f(function(_, parent)
			local full_set = {}
			local newgv = parent.snippet.env.POSTFIX_MATCH
			local graphviz_template = "basic"
			os.execute(generate_command(graphviz_template, newgv))
			table.insert(full_set, image_link_format(newgv))
			table.insert(full_set, "")
			table.insert(full_set, graphviz_link_format(newgv))
			return full_set
		end, {}, {}),
	}),
	postfix({ trig = ".two.svg", dscr = "creat a two arm svg", snippetType = "autosnippet" }, {
		f(function(_, parent)
			local full_set = {}
			local newgv = parent.snippet.env.POSTFIX_MATCH
			local graphviz_template = "twoarm"
			os.execute(generate_command(graphviz_template, newgv))
			table.insert(full_set, image_link_format(newgv))
			table.insert(full_set, "")
			table.insert(full_set, graphviz_link_format(newgv))
			return full_set
		end, {}, {}),
	}),
	postfix({ trig = ".mini.svg", dscr = "creat a mini svg", snippetType = "autosnippet" }, {
		f(function(_, parent)
			local full_set = {}
			local newgv = parent.snippet.env.POSTFIX_MATCH
			local graphviz_template = "mini"
			os.execute(generate_command(graphviz_template, newgv))
			table.insert(full_set, image_link_format(newgv))
			table.insert(full_set, "")
			table.insert(full_set, graphviz_link_format(newgv))
			return full_set
		end, {}, {}),
	}),
}
