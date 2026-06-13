# Setup (shared by both modes)

`$SKILL` = this skill's base directory (runtime-injected "Base directory for
this skill"). `$DEMO` = a dedicated demo dir, e.g. `/tmp/demo-x`.

## 1. Prerequisites (install only what's missing)

| Tool                       | Needed for        | macOS                             | Linux                                                                                    |
| -------------------------- | ----------------- | --------------------------------- | ---------------------------------------------------------------------------------------- |
| `vhs`                      | scripted mode     | `brew install vhs`                | `go install github.com/charmbracelet/vhs@latest` + `ttyd`, `ffmpeg` from package manager |
| `jq`                       | Stop hook         | `brew install jq`                 | `apt install jq`                                                                          |
| `tmux`, `asciinema`, `agg` | live mode only    | `brew install tmux asciinema agg` | `apt install tmux asciinema` + `cargo install --git https://github.com/asciinema/agg`    |
| `magick`                   | verification step | `brew install imagemagick`        | `apt install imagemagick`                                                                 |

Quick check:

```bash
for t in vhs jq tmux asciinema agg magick; do command -v $t >/dev/null || echo "missing: $t"; done
```

brew resolves vhs's `ttyd`/`ffmpeg` dependencies automatically; vhs also
downloads its own headless browser on first run, so the first render is slow.

## 2. Demo directory

Use a dedicated dir so the Stop hook never leaks into real projects:

```bash
mkdir -p "$DEMO/.claude"
command cp "$SKILL/assets/demo.tape" "$DEMO/"
command cp "$SKILL/assets/settings.json" "$DEMO/.claude/"
# Point the hook at the bundled script (absolute path required):
sd 'REPLACE_WITH_ABSOLUTE_PATH_TO/vhs_stop_hook.sh' "$SKILL/scripts/vhs_stop_hook.sh" "$DEMO/.claude/settings.json"
```

This setup is identical for scripted and live modes.

## Trust dialog (first run in a new dir)

A new dir may show the folder-trust dialog and block the startup wait
(headless `claude -p` does NOT register trust). Probe first: launch `claude`
in a detached tmux pane in that dir, `capture-pane` after ~6s; if the trust
dialog shows, accept it with `Enter` and exit — or handle it in the tape
(`Wait+Screen@30s /trust/` then `Enter`).
