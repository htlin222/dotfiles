local vim = vim
local ls = require "luasnip"
local i = ls.insert_node
local s = ls.snippet
local t = ls.text_node
local f = ls.function_node
local d = ls.dynamic_node
local rep = require("luasnip.extras").rep
local fmta = require("luasnip.extras.fmt").fmta
local helpers = require "lua_snippets.helpers"
local ret_filename = helpers.ret_filename
local get_visual = helpers.get_visual
local postfix = require("luasnip.extras.postfix").postfix
local previous = helpers.previous
local alias = helpers.alias

local function findFilesWithSameName(_, _, _)
  local current_buf = vim.fn.bufname "%"
  local current_file_name = vim.fn.fnamemodify(current_buf, ":t:r")
  local command_template = [[
    rg -i -l "\[\[.*%s.*\]\]" *.md
  ]]
  local command = string.format(command_template, current_file_name)
  local file = io.popen(command, "r")
  local friends = {}
  -- table.insert(friends, "whatever.md")
  for line in file:lines() do
    if line == current_buf then
    -- 如果與 current_buf 相等，則跳過此行
    else
      if line:sub(-3) == ".md" then
        line = "- [[" .. line:sub(1, -4) .. "]] "
      end
      table.insert(friends, line)
    end
  end
  -- 刪除最後一個元素
  print "德不孤，必有鄰🥰"
  return friends
end
local function findHeadingOne(_, _, _)
  local current_buf = vim.fn.bufname "%"
  local current_file_name = vim.fn.fnamemodify(current_buf, ":t:r")
  local command_template = [[grep '^# ' %s.md | sed 's/^# //']]
  local command = string.format(command_template, current_file_name)
  local file = io.popen(command, "r")
  local list_of_headings = {}

  for line in file:lines() do
    local sanitized_line = line:lower():gsub("[^%w%s-]", ""):gsub("%s+", "-")
    local link = string.format("- [%s](#%s)", line, sanitized_line)
    table.insert(list_of_headings, link)
  end
  -- 去掉第一個和最後一個項目
  table.remove(list_of_headings, 1)
  table.remove(list_of_headings, #list_of_headings)
  file:close()

  print "GetAllHeading🥰"
  return list_of_headings
end

local function findFilesWithSameDay(_, _, _)
  local current_buf = vim.fn.bufname "%" -- 取得當前緩衝區的文件名
  -- local current_file_name = vim.fn.fnamemodify(current_buf, ":t:r") -- 提取當前文件的無擴展名文件名
  -- local current_dir = vim.fn.expand("%:p:h") -- 取得當前文件所在目錄的絕對路徑
  local command_template1 = "date -r %s +%%Y-%%m-%%d"
  local get_date_command = string.format(command_template1, current_buf) -- 替換 "my_file.md" 為你實際需要的檔案名稱
  local date_handle = io.popen(get_date_command, "r")
  local date_output = date_handle:read "*a"
  date_handle:close()
  local date = date_output:gsub("\n", "") -- 移除換行字元

  -- 使用 find 命令找到在同一天創建的檔案
  local command_template2 = 'find . -type f -newermt "%s 00:00:00" ! -newermt "%s 23:59:59"'
  local find_command = string.format(command_template2, date, date)

  local file = io.popen(find_command, "r")
  local friends = {}
  -- table.insert(friends, "whatever.md")
  for line in file:lines() do
    if string.sub(line, 3) == current_buf then
    -- 如果與 current_buf 相等，則跳過此行
    else
      if line:sub(-3) == ".md" then
        line = "- [[" .. line:sub(3, -4) .. "]] "
      end
      table.insert(friends, line)
    end
  end
  -- 刪除最後一個元素

  print "不通同日而語🥰"
  return friends
end
-- start to return the snippets from here
return {
  s("friend", {
    i(0),
    t { "", "" },
    t { "", "" },
    t "### Backlink",
    t { "", "" },
    t { "", "" },
    f(findFilesWithSameName, {}, {}),
  }),
  s("sections", {
    i(0),
    t { "", "" },
    t { "", "" },
    f(findHeadingOne, {}, {}),
    t { "", "" },
  }),
  s("sameday", {
    i(0),
    t { "", "" },
    t { "", "" },
    t "### Created in the same day",
    t { "", "" },
    t { "", "" },
    f(findFilesWithSameDay, {}, {}),
  }),
  s(
    { trig = "viki", dscr = "generate wiki link", snippetType = "autosnippet" },
    fmta("[[<>]]<>", {
      d(1, get_visual),
      i(0),
    })
  ),
  s(
    { trig = "ofviki", dscr = "as a [[wikilink of]] \nof this filename" },
    fmta("[[<> of <>|<>]]<>", {
      d(1, get_visual),
      f(ret_filename),
      rep(1),
      i(0),
    })
  ),
  s(
    { trig = "von", dscr = "form previous, \n wiki style" },
    fmta("- from [[<>]] <>", {
      f(previous),
      i(0),
    })
  ),
  s(
    { trig = "isvon", dscr = "form previous\nText only" },
    fmta("<>", {
      f(previous),
    })
  ),
  s(
    { trig = "seealso", dscr = "form previous" },
    fmta("- see also: [[<>]] <>", {
      f(previous),
      i(0),
    })
  ),
  postfix({ trig = ".of", dscr = "the previous word as a wikilink" }, {
    t "- [[",
    f(function(_, parent)
      return parent.snippet.env.POSTFIX_MATCH
    end, {}),
    t " of ",
    f(ret_filename),
    t "|",
    f(function(_, parent)
      return parent.snippet.env.POSTFIX_MATCH
    end, {}),
    t "]]",
  }),
  postfix({ trig = ".wiki", dscr = "as a wikilink" }, {
    f(function(_, parent)
      return "[[" .. parent.snippet.env.POSTFIX_MATCH
    end, {}),
    t "]]",
  }),
  s("ov", {
    t "[[overview and recommendations of ",
    f(ret_filename, {}),
    t "|overview and recommendations]]",
  }),
  s(
    { trig = "dxoutline", dscr = "outline" },
    fmta(
      [=[
      ## Outline of <>

      - [[overview of <>| Overview:]]
      - [[definitions of <>| Definitions:]]
      - [[etiologies of <>| Etiologies:]]
      - [[clinical manifestations of <>| Clinical manifestations:]]
      - [[diagnosis of <>| Diagnosis:]]
      - [[management of <>| Management:]]
      - [[treatment of <>| Treatment:]]
      - [[tldr of <>| TLDR:]]
      - [[references of <>| References: ]]
      - <>
      ]=],
      {
        f(ret_filename),
        f(ret_filename),
        f(ret_filename),
        f(ret_filename),
        f(ret_filename),
        f(ret_filename),
        f(ret_filename),
        f(ret_filename),
        f(ret_filename),
        f(ret_filename),
        i(0),
      }
    )
  ),
  s("def", {
    t "- [[definitions of ",
    f(ret_filename, {}),
    t "|definitions]]",
  }),
  s("eti", {
    t "- [[etiologies of ",
    f(ret_filename, {}),
    t "|etiologies]]",
  }),
  s("mani", {
    t "- [[clinical manifestations of ",
    f(ret_filename, {}),
    t "|clinical manifestations]]",
  }),
  s("ref", {
    t "- [[references of ",
    f(ret_filename, {}),
    t "|references]]",
  }),
  s("tldr", {
    t "- [[TLDR of ",
    f(ret_filename, {}),
    t "|TLDR]]",
  }),
  -- s({ trig = ".ali", dscr = "Alias:\n 加入最近取過的別名" }, {
  -- 	t("[["),
  -- 	f(alias, {}),
  -- 	t("]]"),
  -- }),
  s({ trig = ".toc", dscr = "加入目錄就是讚的" }, {
    t '<!-- _header: "Outline" -->',
    t { "", "", "" },
    t '<!-- _footer: "" -->',
    t { "", "---" },
  }),
  s("badge_link", {
    t { "- [" },
    i(1, { "repo/name" }),
    f(function(args, snip)
      return string.format(
        "](https://github.com/%s) ![](https://img.shields.io/github/stars/%s) ![](https://img.shields.io/github/last-commit/%s) ![](https://img.shields.io/github/commit-activity/y/%s)",
        args[1][1],
        args[1][1],
        args[1][1],
        args[1][1]
      )
    end, { 1 }),
  }),
}
