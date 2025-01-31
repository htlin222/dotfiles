local ls = require "luasnip"
local i = ls.insert_node
local s = ls.snippet
local f = ls.function_node
local postfix = require("luasnip.extras.postfix").postfix
local t = ls.text_node
local d = ls.dynamic_node
local helpers = require "lua_snippets.helpers"
local get_visual = helpers.get_visual
local fmta = require("luasnip.extras.fmt").fmta
-- local date = helpers.date
-- local fmt = require("luasnip.extras.fmt").fmt
-- local types = require("luasnip.util.types")
-- local conds = require("luasnip.extras.conditions")
-- local conds_expand = require("luasnip.extras.conditions.expand")

local current_date = os.date "%Y-%m-%d"

local function insert_at_beginning(beginning_stuff)
  -- Get the current line number
  local line_num = vim.api.nvim_win_get_cursor(0)[1]
  local line_content = vim.api.nvim_get_current_line()
  local new_line_content = beginning_stuff .. line_content
  vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, false, { new_line_content })
end

local function insert_footnote_below_current_line(footnote)
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, current_line, current_line, false, { footnote })
end

return {
  -- s("emph", { t("☛ "), i(1, {}), t(" ☚") }),
  postfix({ trig = "emph", dscr = "強調", snippetType = "autosnippet" }, {
    f(function(_, parent)
      return "_" .. parent.snippet.env.POSTFIX_MATCH .. "_"
    end, {}),
  }),
  postfix({ trig = "strong", dscr = "粗體", snippetType = "autosnippet" }, {
    f(function(_, parent)
      return "**" .. parent.snippet.env.POSTFIX_MATCH .. "**"
    end, {}),
  }),
  postfix({ trig = ".`", dscr = "粗體", snippetType = "autosnippet" }, {
    f(function(_, parent)
      return "`" .. parent.snippet.env.POSTFIX_MATCH .. "` "
    end, {}),
  }),
  postfix({ trig = "))", dscr = "小括號", snippetType = "autosnippet" }, {
    f(function(_, parent)
      return "(" .. parent.snippet.env.POSTFIX_MATCH .. ")"
    end, {}),
  }),
  postfix({ trig = ".]]", dscr = "中括號", snippetType = "autosnippet" }, {
    f(function(_, parent)
      return "[" .. parent.snippet.env.POSTFIX_MATCH .. "]"
    end, {}),
  }),
  postfix({ trig = "}}", dscr = "大括號", snippetType = "autosnippet" }, {
    f(function(_, parent)
      return "{" .. parent.snippet.env.POSTFIX_MATCH .. "}"
    end, {}),
  }),
  postfix({ trig = ".**", dscr = "星號、粗體", snippetType = "autosnippet" }, {
    f(function(_, parent)
      return "**" .. parent.snippet.env.POSTFIX_MATCH .. "**"
    end, {}),
  }),
  s(
    { trig = ".]", dscr = "close by square bracket", snippetType = "autosnippet" },
    fmta("[<>]", {
      d(1, get_visual),
    })
  ),
  s(
    { trig = ".)", dscr = "close by bracket", snippetType = "autosnippet" },
    fmta("(<>)<>", {
      d(1, get_visual),
      i(0),
    })
  ),
  s(
    { trig = ".code", dscr = "code", snippetType = "autosnippet" },
    fmta("`<>`<>", {
      d(1, get_visual),
      i(0),
    })
  ),
  s({ trig = "^*", dscr = "add star", snippetType = "autosnippet" }, {
    f(function(_)
      insert_footnote_below_current_line "\\*Your Text"
    end, {}, {}),
    t "*",
  }),
  s({ trig = "^da", dscr = "add dagger", snippetType = "autosnippet" }, {
    f(function(_)
      insert_footnote_below_current_line "†Your Text"
    end, {}, {}),
    t "†",
  }),
  s({ trig = "^dd", dscr = "add double dagger", snippetType = "autosnippet" }, {
    f(function(_)
      insert_footnote_below_current_line "‡Your Text"
    end, {}, {}),
    t "‡",
  }),
  s({ trig = "^ss", dscr = "add section mark", snippetType = "autosnippet" }, {
    f(function(_)
      insert_footnote_below_current_line "§Your Text"
    end, {}, {}),
    t "§",
  }),
  s({ trig = "^p", dscr = "add paragraph mark", snippetType = "autosnippet" }, {
    f(function(_)
      insert_footnote_below_current_line "¶Your Text"
    end, {}, {}),
    t "¶",
  }),
  s({ trig = " ## ", dscr = "as heading 2", wordTrig = false, snippetType = "autosnippet" }, {
    f(function(_)
      insert_at_beginning "## "
    end, {}, {}),
    i(0),
  }),
  s({ trig = " ### ", dscr = "as heading 2", wordTrig = false, snippetType = "autosnippet" }, {
    f(function(_)
      insert_at_beginning "### "
    end, {}, {}),
    i(0),
  }),
  s("frontmatter", {
    t {
      "---",
      "title: ",
    },
    i(1, "example"),
    t {
      "",
      "slug: ",
    },
    i(2, "slug"),
    t {
      "",
      "draft: false",
      "category: tutorial",
      "date: ",
    },
    t(current_date), -- 自動填入當前日期
    t {
      "",
      "description: ",
      "---",
      "",
    },
  }),
}
