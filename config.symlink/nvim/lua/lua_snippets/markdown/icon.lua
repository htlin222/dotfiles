local ls = require("luasnip")
local f = ls.function_node
local postfix = require("luasnip.extras.postfix").postfix

return {
  -- <i class='bx bx-circle-half' ></i>
  postfix({ trig = ".box", dscr = "boxicon" }, {
    f(function(_, parent)
      return "<i class='bx " .. parent.snippet.env.POSTFIX_MATCH .. "' ></i>"
    end, {}),
  }),
}
