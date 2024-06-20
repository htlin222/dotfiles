local ls = require "luasnip"
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local types = require "luasnip.util.types"
local conds = require "luasnip.extras.conditions"
local conds_expand = require "luasnip.extras.conditions.expand"
local vim = vim

ls.setup {
  history = true,
  update_events = "TextChanged,TextChangedI",
  delete_check_events = "TextChanged",
  ext_opts = {
    [types.choiceNode] = {
      active = {
        virt_text = { { "choiceNode", "Comment" } },
      },
    },
  },
  ext_base_prio = 300,
  ext_prio_increase = 1,
  enable_autosnippets = true,
  store_selection_keys = "<Tab>",
  ft_func = function()
    return vim.split(vim.bo.filetype, ".", true)
  end,
}

local function copy(args)
  return args[1]
end
-- 'recursive' dynamic snippet. Expands to some text followed by itself.
local rec_ls
rec_ls = function()
  return sn(
    nil,
    c(1, {
      -- Order is important, sn(...) first would cause infinite loop of expansion.
      t "",
      sn(nil, { t { "", "\t\\item " }, i(1), d(2, rec_ls, {}) }),
    })
  )
end
-- complicated function for dynamicNode.
local function jdocsnip(args, _, old_state)
  -- !!! old_state is used to preserve user-input here. DON'T DO IT THAT WAY!
  -- Using a restoreNode instead is much easier.
  -- View this only as an example on how old_state functions.
  local nodes = {
    t { "/**", " * " },
    i(1, "A short Description"),
    t { "", "" },
  }

  -- These will be merged with the snippet; that way, should the snippet be updated,
  -- some user input eg. text can be referred to in the new snippet.
  local param_nodes = {}

  if old_state then
    nodes[2] = i(1, old_state.descr:get_text())
  end
  param_nodes.descr = nodes[2]

  -- At least one param.
  if string.find(args[2][1], ", ") then
    vim.list_extend(nodes, { t { " * ", "" } })
  end

  local insert = 2
  for indx, arg in ipairs(vim.split(args[2][1], ", ", true)) do
    -- Get actual name parameter.
    arg = vim.split(arg, " ", true)[2]
    if arg then
      local inode
      -- if there was some text in this parameter, use it as static_text for this new snippet.
      if old_state and old_state[arg] then
        inode = i(insert, old_state["arg" .. arg]:get_text())
      else
        inode = i(insert)
      end
      vim.list_extend(nodes, { t { " * @param " .. arg .. " " }, inode, t { "", "" } })
      param_nodes["arg" .. arg] = inode

      insert = insert + 1
    end
  end

  if args[1][1] ~= "void" then
    local inode
    if old_state and old_state.ret then
      inode = i(insert, old_state.ret:get_text())
    else
      inode = i(insert)
    end

    vim.list_extend(nodes, { t { " * ", " * @return " }, inode, t { "", "" } })
    param_nodes.ret = inode
    insert = insert + 1
  end

  if vim.tbl_count(args[3]) ~= 1 then
    local exc = string.gsub(args[3][2], " throws ", "")
    local ins
    if old_state and old_state.ex then
      ins = i(insert, old_state.ex:get_text())
    else
      ins = i(insert)
    end
    vim.list_extend(nodes, { t { " * ", " * @throws " .. exc .. " " }, ins, t { "", "" } })
    param_nodes.ex = ins
    insert = insert + 1
  end

  vim.list_extend(nodes, { t { " */" } })

  local snip = sn(nil, nodes)
  -- Error on attempting overwrite.
  snip.old_state = param_nodes
  return snip
end
-- Make sure to not pass an invalid command, as io.popen() may write over nvim-text.
local function bash(_, _, command)
  local file = io.popen(command, "r")
  local res = {}
  for line in file:lines() do
    table.insert(res, line)
  end
  return res
end

ls.add_snippets("all", {
  -- trigger is `fn`, second argument to snippet-constructor are the nodes to insert into the buffer on expansion.
  s("class", {
    -- Choice: Switch between two different Nodes, first parameter is its position, second a list of nodes.
    c(1, {
      t "public ",
      t "private ",
    }),
    t "class ",
    i(2),
    t " ",
    c(3, {
      t "{",
      -- sn: Nested Snippet. Instead of a trigger, it has a position, just like insertNodes. !!! These don't expect a 0-node!!!!
      -- Inside Choices, Nodes don't need a position as the choice node is the one being jumped to.
      sn(nil, {
        t "extends ",
        -- restoreNode: stores and restores nodes.
        -- pass position, store-key and nodes.
        r(1, "other_class", i(1)),
        t " {",
      }),
      sn(nil, {
        t "implements ",
        -- no need to define the nodes for a given key a second time.
        r(1, "other_class"),
        t " {",
      }),
    }),
    t { "", "\t" },
    i(0),
    t { "", "}" },
  }),
  -- Alternative printf-like notation for defining snippets. It uses format
  -- string with placeholders similar to the ones used with Python's .format().
  s(
    "fmt1",
    fmt("To {title} {} {}.", {
      i(2, "Name"),
      i(3, "Surname"),
      title = c(1, { t "Mr.", t "Ms." }),
    })
  ),
  -- To escape delimiters use double them, e.g. `{}` -> `{{}}`.
  -- Multi-line format strings by default have empty first/last line removed.
  -- Indent common to all lines is also removed. Use the third `opts` argument
  -- to control this behaviour.
  s(
    "fmt2",
    fmt(
      [[
		foo({1}, {3}) {{
			return {2} * {4}
		}}
		]],
      {
        i(1, "x"),
        rep(1),
        i(2, "y"),
        rep(2),
      }
    )
  ),
  -- Empty placeholders are numbered automatically starting from 1 or the last
  -- value of a numbered placeholder. Named placeholders do not affect numbering.
  s(
    "fmt3",
    fmt("{} {a} {} {1} {}", {
      t "1",
      t "2",
      a = t "A",
    })
  ),
  -- The delimiters can be changed from the default `{}` to something else.
  s("fmt4", fmt("foo() { return []; }", i(1, "x"), { delimiters = "[]" })),
  -- `fmta` is a convenient wrapper that uses `<>` instead of `{}`.
  s("fmt5", fmta("foo() { return <>; }", i(1, "x"))),
  -- By default all args must be used. Use strict=false to disable the check
  s("fmt6", fmt("use {} only", { t "this", t "not this" }, { strict = false })),
  s("date", { d(1, date_input, {}, { user_args = { "%Y-%m-%d" } }) }),
  ls.parser.parse_snippet("lspsyn", "Wow! This ${1:Stuff} really ${2:works. ${3:Well, a bit.}}"),
  ls.parser.parse_snippet({ trig = "te", wordTrig = false }, "${1:cond} ? ${2:true} : ${3:false}"),
  ls.parser.parse_snippet({ trig = "%d", regTrig = true }, "A Number!!"),
  s("cond", {
    t "will only expand in c-style comments",
  }, {
    condition = function(line_to_cursor, matched_trigger, captures)
      -- optional whitespace followed by //
      return line_to_cursor:match "%s*//"
    end,
  }),
  -- there's some built-in conditions in "luasnip.extras.conditions.expand" and "luasnip.extras.conditions.show".
  s("cond2", {
    t "will only expand at the beginning of the line",
  }, {
    condition = conds_expand.line_begin,
  }),
  s("cond3", {
    t "will only expand at the end of the line",
  }, {
    condition = conds_expand.line_end,
  }),
  -- on conditions some logic operators are defined
  s("cond4", {
    t "will only expand at the end and the start of the line",
  }, {
    -- last function is just an example how to make own function objects and apply operators on them
    condition = conds_expand.line_end + conds_expand.line_begin * conds.make_condition(function()
      return true
    end),
  }),
  -- The last entry of args passed to the user-function is the surrounding snippet.
  s(
    { trig = "a%d", regTrig = true },
    f(function(_, snip)
      return "Triggered with " .. snip.trigger .. "."
    end, {})
  ),
  -- It's possible to use capture-groups inside regex-triggers.
  s(
    { trig = "b(%d)", regTrig = true },
    f(function(_, snip)
      return "Captured Text: " .. snip.captures[1] .. "."
    end, {})
  ),
  s({ trig = "c(%d+)", regTrig = true }, {
    t "will only expand for even numbers",
  }, {
    condition = function(line_to_cursor, matched_trigger, captures)
      return tonumber(captures[1]) % 2 == 0
    end,
  }),
  -- Use a function to execute any shell command and print its text.
  s("transform", {
    i(1, "initial text"),
    t { "", "" },
    -- lambda nodes accept an l._1,2,3,4,5, which in turn accept any string transformations.
    -- This list will be applied in order to the first node given in the second argument.
    l(l._1:match("[^i]*$"):gsub("i", "o"):gsub(" ", "_"):upper(), 1),
  }),

  s("transform2", {
    i(1, "initial text"),
    t "::",
    i(2, "replacement for e"),
    t { "", "" },
    -- Lambdas can also apply transforms USING the text of other nodes:
    l(l._1:gsub("e", l._2), { 1, 2 }),
  }),
  s({ trig = "trafo(%d+)", regTrig = true }, {
    -- env-variables and captures can also be used:
    l(l.CAPTURE1:gsub("1", l.TM_FILENAME), {}),
  }),
  -- Set store_selection_keys = "<Tab>" (for example) in your
  -- luasnip.config.setup() call to populate
  -- TM_SELECTED_TEXT/SELECT_RAW/SELECT_DEDENT.
  -- In this case: select a URL, hit Tab, then expand this snippet.
  s("link_url", {
    t '<a href="',
    f(function(_, snip)
      -- TM_SELECTED_TEXT is a table to account for multiline-selections.
      -- In this case only the first line is inserted.
      return snip.env.TM_SELECTED_TEXT[1] or {}
    end, {}),
    t '">',
    i(1),
    t "</a>",
    i(0),
  }),
  -- Shorthand for repeating the text in a given node.
  s("repeat", { i(1, "text"), t { "", "" }, rep(1) }),
  -- Directly insert the ouput from a function evaluated at runtime.
  s("today", p(os.date, "%Y-%m-%d")),
  -- use matchNodes (`m(argnode, condition, then, else)`) to insert text
  -- based on a pattern/function/lambda-evaluation.
  -- It's basically a shortcut for simple functionNodes:
  s("mat", {
    i(1, { "sample_text" }),
    t ": ",
    m(1, "%d", "contains a number", "no number :("),
  }),
  -- The `then`-text defaults to the first capture group/the entire
  -- match if there are none.
  s("mat2", {
    i(1, { "sample_text" }),
    t ": ",
    m(1, "[abc][abc][abc]"),
  }),
  -- It is even possible to apply gsubs' or other transformations
  -- before matching.
  s("mat3", {
    i(1, { "sample_text" }),
    t ": ",
    m(1, l._1:gsub("[123]", ""):match "%d", "contains a number that isn't 1, 2 or 3!"),
  }),
  -- `match` also accepts a function in place of the condition, which in
  -- turn accepts the usual functionNode-args.
  -- The condition is considered true if the function returns any
  -- non-nil/false-value.
  -- If that value is a string, it is used as the `if`-text if no if is explicitly given.
  s("mat4", {
    i(1, { "sample_text" }),
    t ": ",
    m(1, function(args)
      -- args is a table of multiline-strings (as usual).
      return (#args[1][1] % 2 == 0 and args[1]) or nil
    end),
  }),
  -- The nonempty-node inserts text depending on whether the arg-node is
  -- empty.
  s("nempty", {
    i(1, "sample_text"),
    n(1, "i(1) is not empty!"),
  }),
  -- dynamic lambdas work exactly like regular lambdas, except that they
  -- don't return a textNode, but a dynamicNode containing one insertNode.
  -- This makes it easier to dynamically set preset-text for insertNodes.
  s("dl1", {
    i(1, "sample_text"),
    t { ":", "" },
    dl(2, l._1, 1),
  }),
  s("hdh2", {
    t { "<!-- header: '" },
    dl(2, l._1, 1),
    t { "' -->", "", "## " },
    i(1, "sample_title"),
  }),
  s("hdh1", {
    t { "<!-- header: '" },
    dl(2, l._1, 1),
    t { "' -->", "", "# " },
    i(1, "sample_title"),
  }),
  -- The last entry of args passed to the user-function is the surrounding snippet.
  s(
    { trig = "a%d", regTrig = true },
    f(function(_, snip)
      return "Triggered with " .. snip.trigger .. "."
    end, {})
  ),
  -- It's possible to use capture-groups inside regex-triggers.
  s(
    { trig = "b(%d)", regTrig = true },
    f(function(_, snip)
      return "Captured Text: " .. snip.captures[1] .. "."
    end, {})
  ),
  s({ trig = "c(%d+)", regTrig = true }, {
    t "will only expand for even numbers",
  }, {
    condition = function(line_to_cursor, matched_trigger, captures)
      return tonumber(captures[1]) % 2 == 0
    end,
  }),
  -- Obviously, it's also possible to apply transformations, just like lambdas.
  s("dl2", {
    i(1, "sample_text"),
    i(2, "sample_text_2"),
    t { "", "" },
    dl(3, l._1:gsub("\n", " linebreak ") .. l._2, { 1, 2 }),
  }),
}, {
  key = "all",
})

ls.add_snippets("tex", {
  s("ls", {
    t { "\\begin{itemize}", "\t\\item " },
    i(1),
    d(2, rec_ls, {}),
    t { "", "\\end{itemize}" },
  }),
}, {
  key = "tex",
})
-- set type to "autosnippets" for adding autotriggered snippets.
ls.add_snippets("all", {
  s("autotrigger", { t "autosnippet" }),
  s("abx", { t "antibiotics" }),
}, { type = "autosnippets", key = "all_auto" })

require("luasnip.loaders.from_lua").lazy_load {
  paths = { vim.fn.stdpath "config" .. "/lua/lua_snippets" },
}

-- Load this line is important for friendly-snippets
-- [rafamadriz/friendly-snippets: Set of preconfigured snippets for different languages.](https://github.com/rafamadriz/friendly-snippets)
require("luasnip.loaders.from_vscode").lazy_load()
-- Load my personal snippets from lua/vscode_snippets
require("luasnip.loaders.from_vscode").lazy_load {
  paths = { vim.fn.stdpath "config" .. "/lua/vscode_snippets" },
}
