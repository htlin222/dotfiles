# Live / Adaptive Mode (tmux + asciinema)

Drive a real inner Claude Code session interactively: read each response,
decide the next prompt from its content, and record everything as a `.cast`.
Use when prompts must react to the inner session's output — impossible with
VHS, whose tape is fixed before the run.

Requires: `tmux`, `asciinema`, `agg` (for GIF conversion). Install commands and
demo-directory staging (hook + settings.json, identical to scripted mode) are
in [setup.md](setup.md).

## Loop pattern (all commands tested)

```bash
DEMO=/tmp/demo-x   # dir with .claude/settings.json hook staged

# 1. Start inner Claude under asciinema in a detached tmux pane
tmux kill-session -t vhsdemo 2>/dev/null
tmux new-session -d -s vhsdemo -x 130 -y 35 -c "$DEMO" \
  'env VHS_DEMO=1 asciinema rec demo.cast -c claude'

# 2. Wait for startup
for i in $(seq 1 30); do
  tmux capture-pane -p -t vhsdemo | grep -qE 'shortcuts|Welcome' && break
  sleep 2
done

# 3. Send a prompt (text and Enter as separate sends, ~1s apart)
tmux send-keys -t vhsdemo "first prompt here" && sleep 1 && tmux send-keys -t vhsdemo Enter

# 4. Poll for the turn-N sentinel (bump N each turn)
for i in $(seq 1 60); do
  tmux capture-pane -p -t vhsdemo | grep -q 'VHS_TURN_DONE_1' && break
  sleep 2
done

# 5. Read the response, then DECIDE the next prompt from its content
tmux capture-pane -p -t vhsdemo | grep -A5 '⏺'

# ... repeat 3-5 with VHS_TURN_DONE_2, _3, ... ...

# 6. Exit cleanly and convert
sleep 5
tmux send-keys -t vhsdemo C-c; sleep 1; tmux send-keys -t vhsdemo C-c; sleep 3
tmux kill-session -t vhsdemo 2>/dev/null
# agg: --font-size sets raster resolution (28+ for 2x-crisp);
# light mode: --theme github-light
agg --font-size 20 "$DEMO/demo.cast" "$DEMO/demo.gif"
```

## Notes

- **Incrementing sentinels are essential here**: old `VHS_TURN_DONE_N`
  markers linger in the pane, so always grep for the exact next number.
- `capture-pane -p` shows only the visible screen. For responses that
  scrolled off, add `-S -200` (200 lines of scrollback), or read the inner
  session's transcript directly: the Stop hook's stdin JSON contains
  `transcript_path` — extend the hook to copy it somewhere known, then
  parse the JSONL for the verbatim response text.
- `agg` progress output is noisy; redirect to /dev/null in scripts.
- Adjust the poll budget (step 4) upward for prompts that trigger tool use.
- The `.cast` is the source of truth — keep it; GIF/MP4 are derived.

## Codex CLI: sentinel works there too (tested on 0.135)

Codex has a full hooks system mirroring Claude Code's, including `Stop`
with on-screen `systemMessage`. The SAME `vhs_stop_hook.sh` works unchanged
(Codex also passes `session_id` on stdin, so per-session counters and
rerun-starts-at-1 hold). Add to `~/.codex/config.toml` (global — there is
no per-project config, but the `$VHS_DEMO` gate keeps it inert):

```toml
# VHS demo sentinel — gated on $VHS_DEMO; inert in normal sessions
[[hooks.Stop]]

[[hooks.Stop.hooks]]
type = "command"
command = "/absolute/path/to/vhs_stop_hook.sh"
timeout = 10
```

Caveats (Codex is fussier than Claude under VHS — `gen_tape.py --agent codex`
handles all of these; hand-author only if you must):

- One-time trust: next launch shows a hook review screen — press `t` to
  trust. Do this in a tmux probe before recording, or the review screen
  ruins the take. Re-trust is needed whenever the hook command path changes.
- Sentinel renders as `• Stop hook (completed)` + `warning: VHS_TURN_DONE_N`.
- **Ready gate = the status line, not the splash.** Wait for `/% left/`
  (the "5h .. % left · weekly .. % left" status line), NOT `/model to
change/`. Codex accepts typed characters into the composer early but DROPS
  the submit Enter until the TUI finishes loading — which is when the status
  line appears. Submitting against the splash silently fails.
- **No word-by-word typing.** Chunked per-word `Type` bursts are read as a
  paste and then Enter won't submit; type the whole prompt with one smooth
  `Type` (~55ms/char). Word-by-word is Claude-only.
- Double-tap Enter (`Enter; Sleep 1s; Enter`) to guard an intermittently
  dropped keypress.
- Startup may show an update banner and a "skills shortened" warning; the
  status-line gate above waits past them.

**Codex + scripted VHS is UNRELIABLE — prefer live tmux mode for Codex.**
Measured on Codex 0.135 / vhs 0.10 in an env with many plugins: scripted
submission failed ~6/7 attempts. Codex shows async startup notices (update
banner, and a "skills shortened to fit the 2% budget" warning when many
plugins are enabled) that land mid-submit and eat the Enter, leaving the
prompt unsent. The ready-status-line gate and double-Enter help but don't
make it deterministic. `gen_tape.py --agent codex` emits a best-effort tape
(smooth typing, status-line gate, double-Enter, Sleep-based turns 2+), but
**for reliable Codex demos use live tmux mode** — there you poll the screen,
wait for the sentinel, and only advance once submission is confirmed
(verified 4/4). The loop above works as-is for Codex; just use the Codex
busy/ready markers. Claude Code scripted VHS is NOT affected.

## Other TUIs without Stop hooks

The same loop records any agent TUI; only completion detection changes.
Replace the sentinel grep with: busy marker absent AND two consecutive
`capture-pane` snapshots identical:

```bash
prev=""
for i in $(seq 1 60); do
  cur=$(tmux capture-pane -p -t demo)
  if ! echo "$cur" | grep -q 'esc to interrupt'; then   # the TUI's busy marker
    [ "$cur" = "$prev" ] && break
  fi
  prev="$cur"; sleep 2
done
```

(Verified against Codex before its Stop hook was configured: the busy
marker stayed up through mid-turn web searches, so the check survives
them.) Exit with two `C-c` sends; the session may end itself, making a
later `kill-session` fail harmlessly.
