return {
  hide_tab_bar_if_only_one_tab = true,
  check_for_updates = false,
  keys = {
    -- font size management for AZERTY keyboard
    {mods = "CTRL|SHIFT", key = "°", action = "ResetFontSize"}, -- Ctrl-Shift-°
    {mods = "CTRL|SHIFT", key = "6", action = "DecreaseFontSize"}, -- Ctrl-Shift-- (key with -)
    {mods = "CTRL|SHIFT", key = "+", action = "IncreaseFontSize"}, -- Ctrl-Shift-+ (key with =)
  },
  adjust_window_size_when_changing_font_size = false,
}
