-- Define mods helper, to have a short way to create mods values
-- (e.g: mods._ for NONE, mods.CA for CTRL|ALT)
local mods = setmetatable({
  _SHORT_MOD_MAP = {
    _ = "NONE",
    C = "CTRL",
    S = "SHIFT",
    A = "ALT",
    D = "SUPER", -- D for Desktop (Win/Cmd/Super)
  }
}, {
  -- Dynamically transform key access of 'CSA' to 'CTRL|SHIFT|ALT'
  __index = function(self, key)
    local resolved_mods = self._SHORT_MOD_MAP[key:sub(1, 1)]
    for i = 2, #key do
      local char = key:sub(i, i)
      resolved_mods = resolved_mods .. "|" .. self._SHORT_MOD_MAP[char]
    end
    return resolved_mods
  end,
})

return {
  mods = mods,
}
