---
name: agent-demo-recorder
description: Record demo GIFs/MP4s of agent TUI sessions (Claude Code, Codex CLI, other agent CLIs), synchronized via a Stop-hook sentinel so the recording knows exactly when each response finishes. Two modes - scripted (VHS tape, repeatable) and live/adaptive (tmux + asciinema, where the outer Claude reads each inner response and decides the next prompt). Use when the user wants to record, capture, or make a demo/GIF/video of a Claude Code or Codex session, create a .tape file, drive a nested agent session interactively, or asks about VHS/asciinema recording of an agent CLI.
---

# Agent Demo Recorder

Record a nested agent TUI session (Claude Code, Codex CLI, ...) as a
GIF/MP4. The workflow below uses Claude Code as the running example; for
Codex and hook-less TUIs see [references/live-mode.md](references/live-mode.md).
VHS spawns its own headless terminal (ttyd + browser), so running it from
inside a Claude Code session is safe — the inner session is fully
independent.

## Mode selection

- **Scripted (VHS)** — prompts known in advance, polished repeatable output.
  This is the default; workflow below.
- **Live/adaptive (tmux + asciinema)** — the next prompt must depend on what
  the inner Claude actually answered (outer Claude reads each response and
  decides the follow-up). VHS cannot do this; see
  [references/live-mode.md](references/live-mode.md) for the tested loop
  pattern. Demo-directory setup (step 2 below) is shared by both modes.

**Core problem this skill solves**: Claude Code response times are
non-deterministic and its UI text is theme/statusline-dependent, so fixed
`Sleep`s and default-UI regexes are fragile. The fix: a Stop hook prints an
on-screen sentinel (`VHS_TURN_DONE_N`) exactly when each turn ends, and the
tape waits on it with `Wait+Screen`.

## Workflow

Let `$SKILL` be this skill's base directory (from the runtime-injected
"Base directory for this skill" value).

1. **Check prerequisites** (install only what's missing):

   | Tool | Needed for | macOS | Linux |
   |------|-----------|-------|-------|
   | `vhs` | scripted mode | `brew install vhs` | `go install github.com/charmbracelet/vhs@latest` + `ttyd`, `ffmpeg` from package manager |
   | `jq` | Stop hook | `brew install jq` | `apt install jq` |
   | `tmux`, `asciinema`, `agg` | live mode only | `brew install tmux asciinema agg` | `apt install tmux asciinema` + `cargo install --git https://github.com/asciinema/agg` |
   | `magick` | verification step | `brew install imagemagick` | `apt install imagemagick` |

   Quick check: `for t in vhs jq tmux asciinema agg magick; do command -v $t >/dev/null || echo "missing: $t"; done`
   (brew resolves vhs's `ttyd`/`ffmpeg` dependencies automatically; vhs also
   downloads its own headless browser on first run, so the first render is slow.)

2. **Set up the demo directory** (use a dedicated dir, e.g. `/tmp/demo-x`,
   so the hook never leaks into real projects):

   ```bash
   mkdir -p "$DEMO/.claude"
   command cp "$SKILL/assets/demo.tape" "$DEMO/"
   command cp "$SKILL/assets/settings.json" "$DEMO/.claude/"
   # Point the hook at the bundled script (absolute path required):
   sd 'REPLACE_WITH_ABSOLUTE_PATH_TO/vhs_stop_hook.sh' "$SKILL/scripts/vhs_stop_hook.sh" "$DEMO/.claude/settings.json"
   ```

3. **Generate the tape** (preferred — VHS has no functions, so authoring
   word-by-word typing by hand is verbose). `scripts/gen_tape.py` takes a
   clean prompt list and emits the full tape with word-by-word reveal, a 3s
   read-pause before Enter, sentinel waits, per-turn counters, and the
   per-agent quirks baked in:

   ```bash
   python3 "$SKILL/scripts/gen_tape.py" --agent claude -o "$DEMO/demo.tape" \
     "explain what a tape file is in one sentence" \
     "now show a two-line example"          # each arg = one turn
   ```

   Flags: `--theme dark|light`, `--scale 2` (2x DPI), `--font-size N`
   (default 27), `--word-delay ms` (default 220), `--read-pause s` (default
   3), `--agent claude|codex`. The hand-written `assets/demo.tape` /
   `assets/codex.tape` remain as editable references if you need a shape the
   generator doesn't produce.

4. **Render**: `cd "$DEMO" && vhs demo.tape`. Run in background; renders
   take roughly (Claude response time + ~15s overhead). Exit 0 means all
   waits matched. On `Wait` timeout, the error prints the last screen
   content — read it to see what actually rendered. Startup can be slow
   (large model + MCP + hooks), so the startup wait is 60s; bump it if you
   still time out on the loading splash.

5. **Verify visually**: extract a frame from just after the last sentinel
   matched and Read it. The GIF encodes at 25fps, so with the template's 5s
   hold + ~1.5s exit tail, that frame sits ~150 from the end:

   ```bash
   command magick claude-demo.gif -coalesce -swap -150,0 -delete 1--1 check.png
   ```

   Confirm the response and `Stop says: VHS_TURN_DONE_N` are visible (if the
   frame shows a mid-generation spinner instead, probe a smaller offset).
   Delete the check frame afterward.

6. **(Optional) Wrap as a play/pause HTML** — `scripts/gen_html.py` makes a
   self-contained, batteries-included `.html` that opens offline and plays
   with real controls:

   ```bash
   # GIF -> self-contained HTML5 <video> (auto-converts to mp4 via ffmpeg)
   python3 "$SKILL/scripts/gen_html.py" claude-demo.gif -o demo.html
   # Best quality: render mp4 directly, then wrap
   python3 "$SKILL/scripts/gen_tape.py" --agent claude --format mp4 ... -o d.tape
   python3 "$SKILL/scripts/gen_html.py" claude-demo.mp4 -o demo.html
   # Live-mode .cast -> by default rendered in the VHS LOOK (Catppuccin +
   # JetBrains Mono via agg) as an HTML5 video, so cast demos match VHS ones:
   python3 "$SKILL/scripts/gen_html.py" session.cast -o demo.html --theme dark
   #   add --player for asciinema-player instead (selectable text)
   ```

   GIFs can't be paused, so every path produces an HTML5 `<video controls>`
   (play/pause/seek) except `--player`. **`.cast` defaults to the VHS look** —
   the matching Catppuccin palette is injected into the cast header and agg
   (JetBrains Mono by default) renders it, so live-mode demos look identical to
   scripted VHS ones. `--player` switches to asciinema-player (selectable text,
   embedded offline; `--cdn` for smaller). All outputs verified rendering in a
   headless browser. Requires `ffmpeg` (gif/cast→mp4) and `agg` (cast look).

## Tape-writing notes

- **Codex can't do word-by-word typing under VHS** — its composer reads the
  chunked per-word `Type` bursts as a paste and then Enter won't submit.
  `gen_tape.py` handles this automatically: Claude gets word-by-word, Codex
  gets smooth single-`Type` typing. Don't hand-author word-by-word Codex tapes.

- Startup detection waits on `/shift\+tab|for shortcuts/` — the composer
  footer, which is layout-independent (the welcome BOX text varies: a large
  font yields a compact welcome with no "Welcome"/tips, so don't match that).
- Adjust `Wait` timeouts for prompts that trigger tool use or long thinking
  (default 120s suits chat-only answers).
- The sentinel renders as `⎿ Stop says: VHS_TURN_DONE_N` under the response.
- Exit with two `Ctrl+C` presses ~500ms apart.
- Long responses inflate GIF size; prefer short prompts, `--format mp4`, or
  wrap as HTML video (step 6).
- First run in a new dir may show the folder-trust dialog and block the
  startup wait (headless `claude -p` does NOT register trust). Probe first:
  launch `claude` in a detached tmux pane in that dir, `capture-pane` after
  ~6s; if the trust dialog shows, accept it with `Enter` and exit — or
  handle it in the tape (`Wait+Screen@30s /trust/` then `Enter`).

## Sentinel mechanism (for debugging)

`scripts/vhs_stop_hook.sh` is a Stop hook gated on `$VHS_DEMO` (set by the
tape's `Env` command, inherited by the inner session). It reads `session_id`
from the hook's stdin JSON, increments `${TMPDIR:-/tmp}/vhs-demo-<sid>.count`,
and prints `{"systemMessage": "VHS_TURN_DONE_<n>"}` — Claude Code renders
systemMessage on screen, which is the only thing VHS can wait on (it cannot
watch files or processes). Counter files are per-session so reruns start at 1.
