# herdr config

`config.toml` ports the Ctrl-a tmux workflow from
[`tmux/tmux.conf.symlink`](../../tmux/tmux.conf.symlink) onto
[herdr](https://herdr.dev) (v0.7.1), a terminal workspace manager built
specifically for AI coding agents (panes report agent state; there's a
built-in agent panel, agent-cycling keys, and per-agent notifications —
things tmux only got via the custom scripts below).

Docs used: `herdr --help`, `herdr --default-config`,
https://herdr.dev/docs/cli-reference/, `/docs/keyboard/`, `/docs/configuration/`.

Reload after editing: `herdr server reload-config` (or the in-app global
menu). Validate first — invalid values fall back silently with a startup
warning, so always check `herdr server reload-config`'s JSON output for
`"diagnostics"` after a change.

## Prefix

tmux ran `set -g prefix None` plus a manual `C-a` binding, purely so it
could run `im-select` (switch macOS input source to ABC) before entering
prefix mode — a workaround because tmux has no native hook for this.

herdr has that exact feature built in:

```toml
[experimental]
switch_ascii_input_source_in_prefix = true
```

So `prefix = "ctrl+a"` is now a first-class setting, no shell hook needed.

## 1:1 / near-1:1 mappings

| Key | tmux behavior | herdr action |
|---|---|---|
| `prefix+r` | `source-file ~/.tmux.conf` | `reload_config` (moved off herdr's default `prefix+shift+r`, which is now free) |
| `prefix+c` | `new-window` | `new_tab` (already herdr's default) |
| `prefix+h/j/k/l` | `select-pane -L/-D/-U/-R` | `focus_pane_left/down/up/right` (already herdr's default) |
| `ctrl+h/j/k/l` (no prefix) | *(vim-tmux-navigator habit)* | added as extra bindings on `focus_pane_*` — direct pane navigation, no prefix. **Trade-off:** panes no longer receive raw `C-h/j/k/l` (shell clear-screen on `C-l`, readline `C-k`, in-pane vim window nav, etc.); use `prefix+h/j/k/l` or arrows if an app needs those keys |
| `alt+←/→/↑/↓` (no prefix) | `select-pane` (matches tmux's `alt+←/→/↑/↓`) | added as a second binding on the same `focus_pane_*` actions |
| `shift+←/→` (no prefix) | `previous-window` / `next-window` | `previous_tab` / `next_tab` (moved off `prefix+p/n`, see below) |
| `prefix+p` / `prefix+n` | *(no tmux equivalent — workspace-level prev/next)* | `previous_workspace` / `next_workspace` — freed up since tab switching already has `shift+←/→` |
| `ctrl+q` (no prefix) | `detach-client` | added to `detach` alongside herdr's default `prefix+q` |
| `prefix+b` | `split-window -h` (side-by-side) | `split_vertical` — tmux's `-h` flag is a side-by-side split, which is what herdr calls a "vertical divider" |
| `prefix+v` | `split-window -v` (stacked) | `split_horizontal` — same naming inversion, other direction |
| `shift+↑/↓` (no prefix) | `tmux_claude_nav.sh prev/next` | `previous_agent` / `next_agent` — **native herdr feature**, the custom script is no longer needed |
| `ctrl+g` (no prefix) | `tmux_claude_switcher.sh` popup | added to `goto` alongside `prefix+g` — herdr's built-in agent/workspace panel replaces the custom popup script |
| `prefix+T` | `sesh connect $(sesh list \| fzf)` | **not ported as a custom command** — see below |

Because `split_vertical`/`split_horizontal` were reassigned to `b`/`v`,
`toggle_sidebar` (herdr's default `prefix+b`) was moved to
`prefix+shift+b`. tmux had no sidebar concept, so there was nothing to
collide with there.

## Resize: `prefix+H/J/K/L`

tmux used `bind -r H/J/K/L resize-pane -L/-D/-U/-R 5` — direct, repeatable,
no modal entry. herdr only exposes a modal `resize_mode` action in
`[keys]`, but the CLI has `herdr pane resize --direction <dir> --amount
<FLOAT>`, so the same direct/repeatable feel is ported as four custom
commands instead of using `resize_mode`:

```toml
resize_mode = ""   # unused; direct commands below replace it
[[keys.command]]
key = "prefix+shift+h"
type = "shell"
command = "herdr pane resize --direction left --amount 5"
```
(and `j`/`k`/`l` for down/up/right)

**Unverified:** `--amount`'s unit isn't documented in `herdr pane resize
--help`. `5` is carried over from tmux's cell count as a starting guess —
try it and adjust if a resize step feels too big/small.

## Approximated, not equivalent

- **`prefix+a`** (tmux: `split-window -v -l 3`, a small fixed-height
  stacked split) → `herdr pane split --direction down --ratio 0.15`.
  herdr has no fixed-line split, only `--ratio`, so `0.15` is a guess at
  "3 lines" on a typical pane height. Adjust to taste.

## Ported via plugin

- **`prefix+i`** (tmux: `tmux_popup.sh`, a *floating* popup pane that
  doesn't consume the layout) → a **real port** via the
  [htlin222/herdr-floax](https://github.com/htlin222/herdr-floax) fork
  of Tyru5/herdr-floax, pinned in `plugins.list`: `type =
  "plugin_action"`, `command = "herdr-floax.toggle"`. Toggles a
  centered floating scratch shell (90%×80%, same as the old tmux
  popup); the shell session persists across toggles. The fork (commit
  `c002052`, branch `floax-native-popup` = `main`) adds on top of
  upstream:
  - **snapshot backdrop** — the toggle script captures every pane of
    the current tab (`herdr pane layout` + `herdr pane read --format
    ansi`) and the app paints that content dimmed behind the box
    (`src/snapshot.rs`), so the popup floats over the *real workspace*
    (a still of open time; plugins can't composite live panes).
  - opens as a borderless single-pane **tab** (`--placement tab`)
    instead of split+zoom, so the backdrop lines up 1:1 (a zoomed
    split gets a 1-cell herdr pane border that crops/offsets it).
  - config keys `border` / `border_type` / `box_bg` / `title` —
    `floax.conf` here sets accent-blue `#89b4fa` plain border and
    `box_bg #181825` to match herdr's native modal chrome
    (`render_modal_shell` in herdr's source), and title defaults to
    the **basename of the launch directory**.

  All knobs live in `plugins/config/herdr-floax/floax.conf` (tracked
  in git; see the fork's `floax.conf.example`). Building needs a Rust
  toolchain — note the Homebrew `rust` formula can break when `brew
  autoremove` drops its `llvm` dep; the rustup toolchain in
  `~/.cargo/bin` is what `make install` should use. This replaces the
  old approximation (`herdr pane split --direction down --ratio 0.25
  --focus`, an in-layout split).

## Not ported — no herdr equivalent

- **`prefix+T` → sesh popup.** `sesh` manages *tmux* sessions specifically;
  invoking it from inside herdr would spawn a mismatched tmux session
  rather than switch herdr workspaces. The right herdr-native tool for
  "jump to another named session" is already bound:
  `workspace_picker = "prefix+w"` (fuzzy picker) and `goto = "prefix+g"`.
  No custom command was added for `T`.
- **Copy-mode / vi selection** (`Escape` → copy-mode, `prefix+/` regex
  search, `v`/`y`/`r` in `copy-mode-vi`). herdr isn't modal like tmux's
  copy-mode — there's no equivalent surface in the CLI or config
  reference. Native terminal scrollback + selection (OSC 52, same as
  tmux's `set-clipboard on` + tmux-yank) is the fallback.
- **`tmux-jump` plugin** (`@jump-key = 's'`, easymotion-style pane-text
  jump). No equivalent; herdr's default `settings = "prefix+s"` was left
  alone since nothing else claims that key.
- **`prefix+p` → `paste-buffer`.** tmux's own default `prefix+p` is
  `previous-window`, but this config had unbound it and rebound `p` to
  paste a tmux copy-buffer — a concept herdr doesn't have (no modal
  buffer system). herdr's default `previous_tab = "prefix+p"` was
  reassigned to `previous_workspace` instead (see table above); tab
  switching still works via `shift+←/→`. There's nothing to port
  `paste-buffer` to either way.

## Mouse

tmux's mouse config was a fairly involved conditional passthrough (native
terminal selection vs. copy-mode vs. alternate-screen apps). herdr's
`[ui] mouse_capture` is a coarser on/off switch — left at its default
(`true`) here. Set it `false` if you'd rather the terminal always handle
clicks/selection natively, closer to what the tmux passthrough rules were
approximating.

## Everything else in `config.toml`

Every non-`[keys]`/`[experimental]` section is left as herdr's commented
default (this file was generated from `herdr --default-config` and edited
in place) — treat those comments as the reference for future tweaks
(theme, sounds, toasts, sidebar sizing, etc.), not as things this port
touched.
