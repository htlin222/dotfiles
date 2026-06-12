# hammerspoon — macOS automation

Linked as `~/.hammerspoon`. Modular `init.lua` that requires per-feature
modules; many modules exist but only a few are enabled (currently: reload,
vimmode, caffeinate, wificontext, urlscheme). Enable/disable by
(un)commenting the `require` in `init.lua`.

- **Hyper key**: F18 (Karabiner maps a physical key) — app launchers on
  Hyper+letter, window management (50/50 splits, maximize, 3×3 grid).
- **VimMode**: `jk` enters vim-style editing in any text field.
- Background modules: caffeinate (sleep control), wificontext (act on
  SSID change), urlscheme handlers, app-idle tracker.

After edits, reload Hammerspoon config (auto-reload module watches this
dir) and check the Hammerspoon console for Lua errors.
