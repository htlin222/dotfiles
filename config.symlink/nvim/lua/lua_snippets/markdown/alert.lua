local ls = require "luasnip"
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
return {
  -- s({ trig = "free" }, { t("test") }),
  s({ trig = ">NOTE" }, { t { "> [!NOTE]", "> " }, i(0) }),
  s({ trig = ">TIP" }, { t { "> [!TIP]", "> " }, i(0) }),
  s({ trig = ">IMPORTANT" }, { t { "> [!IMPORTANT]", "> " }, i(0) }),
  s({ trig = ">WARNING" }, { t { "> [!WARNING]", "> " }, i(0) }),
  s({ trig = ">CAUTION" }, { t { "> [!CAUTION]", "> " }, i(0) }),
}

-- > [!NOTE]
-- > Highlights information that users should take into account, even when skimming.
--
-- > [!TIP]
-- > Optional information to help a user be more successful.
--
-- > [!IMPORTANT]
-- > Crucial information necessary for users to succeed.
--
-- > [!WARNING]
-- > Critical content demanding immediate user attention due to potential risks.
--
-- > [!CAUTION]
-- > Negative potential consequences of an action.
