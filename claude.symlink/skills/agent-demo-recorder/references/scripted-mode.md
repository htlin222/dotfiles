# Scripted mode (VHS) — generate, render, verify, wrap

Default mode: prompts known in advance, polished repeatable output. Assumes
[setup.md](setup.md) is done (`$SKILL`, `$DEMO`, hook staged).

## Generate the tape

Preferred over hand-authoring — VHS has no functions, so word-by-word typing
is verbose to write by hand. `scripts/gen_tape.py` takes a clean prompt list
and emits the full tape with word-by-word reveal, a 3s read-pause before
Enter, sentinel waits, per-turn counters, and the per-agent quirks baked in:

```bash
python3 "$SKILL/scripts/gen_tape.py" --agent claude -o "$DEMO/demo.tape" \
  "explain what a tape file is in one sentence" \
  "now show a two-line example"          # each arg = one turn
```

Flags: `--theme dark|light`, `--scale 2` (2x DPI), `--font-size N` (default
27), `--word-delay ms` (default 220), `--read-pause s` (default 3), `--agent
claude|codex`, `--format mp4`. The hand-written `assets/demo.tape` /
`assets/codex.tape` remain as editable references if you need a shape the
generator doesn't produce. See [tape-writing.md](tape-writing.md) for the
per-agent quirks the generator encodes.

## Render

```bash
cd "$DEMO" && vhs demo.tape
```

Run in background; renders take roughly (Claude response time + ~15s
overhead). Exit 0 means all waits matched. On `Wait` timeout, the error
prints the last screen content — read it to see what actually rendered.
Startup can be slow (large model + MCP + hooks), so the startup wait is 60s;
bump it if you still time out on the loading splash.

## Verify visually

Extract a frame from just after the last sentinel matched and Read it. The
GIF encodes at 25fps, so with the template's 5s hold + ~1.5s exit tail, that
frame sits ~150 from the end:

```bash
command magick claude-demo.gif -coalesce -swap -150,0 -delete 1--1 check.png
```

Confirm the response and `Stop says: VHS_TURN_DONE_N` are visible (if the
frame shows a mid-generation spinner instead, probe a smaller offset). Delete
the check frame afterward.

## (Optional) Wrap as play/pause HTML

`scripts/gen_html.py` makes a self-contained, batteries-included `.html` that
opens offline and plays with real controls:

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
