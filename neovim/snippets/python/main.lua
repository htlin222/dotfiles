-- Return snippet tables
local ls = require("luasnip")
local i = ls.insert_node
local t = ls.text_node
local s = ls.snippet
local function copy(args)
	return args[1]
end
return {
	-- Example: how to set snippet parameters
	s(
		{ -- Table 1: snippet parameters
			trig = ":hi:",
			dscr = "An autotriggering snippet that expands 'hi' into 'Hello, world!'",
			regTrig = false,
			priority = 100,
			snippetType = "autosnippet",
		},
		{ -- Table 2: snippet nodes (don't worry about this for now---we'll cover nodes shortly)
			t("Hello, world!"), -- A single text node
		}
		-- Table 3, the advanced snippet options, is left blank.
	),
	s("def", {
		t("# Parameters: "),
		t({ "", "def " }),
		-- Placeholder/Insert.
		i(1),
		t("("),
		-- Placeholder with initial text.
		i(2, "int foo"),
		-- Linebreak
		t({ "):", "\t" }),
		-- Last Placeholder, exit Point of the snippet.
		i(3),
		t({ "\t", "\treturn " }),
		i(0),
	}),
}
