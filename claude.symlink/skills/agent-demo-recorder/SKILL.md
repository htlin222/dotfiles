---
name: agent-demo-recorder
description: Record demo GIFs/MP4s of agent TUI sessions (Claude Code, Codex CLI, other agent CLIs), synchronized via a Stop-hook sentinel so the recording knows exactly when each response finishes. Two modes - scripted (VHS tape, repeatable) and live/adaptive (tmux + asciinema, where the outer Claude reads each inner response and decides the next prompt). Use when the user wants to record, capture, or make a demo/GIF/video of a Claude Code or Codex session, create a .tape file, drive a nested agent session interactively, or asks about VHS/asciinema recording of an agent CLI.
---

# Agent Demo Recorder

Record a nested agent TUI session (Claude Code, Codex CLI, ...) as a GIF/MP4.
VHS spawns its own headless terminal (ttyd + browser), so running it from
inside a Claude Code session is safe — the inner session is fully independent.

**Core problem this skill solves**: agent response times are non-deterministic
and the UI text is theme/statusline-dependent, so fixed `Sleep`s and default-UI
regexes are fragile. The fix: a Stop hook prints an on-screen sentinel
(`VHS_TURN_DONE_N`) exactly when each turn ends, and the recorder waits on it.

`$SKILL` = this skill's base directory (runtime-injected "Base directory for
this skill"). `$DEMO` = a dedicated demo dir, e.g. `/tmp/demo-x`.

## Mode selection

- **Scripted (VHS)** — prompts known in advance, polished repeatable output.
  The default; steps below.
- **Live/adaptive (tmux + asciinema)** — the next prompt must depend on what
  the inner agent actually answered (outer Claude reads each response and
  decides the follow-up). VHS can't do this → [references/live-mode.md](references/live-mode.md).

## Scripted workflow

1. **Setup** — install prereqs, stage the demo dir + hook → [references/setup.md](references/setup.md)
2. **Generate the tape** — `gen_tape.py` from a prompt list → [references/scripted-mode.md](references/scripted-mode.md)
3. **Render** — `cd "$DEMO" && vhs demo.tape` (background; ~response time + 15s)
4. **Verify** — extract a frame near the end, Read it, confirm the sentinel shows
5. **(Optional) Wrap as HTML** — `gen_html.py` → self-contained play/pause video
6. **Teardown** — `cleanup.sh` reaps processes + counter files → [references/cleanup.md](references/cleanup.md)

Steps 2–5 detail: [references/scripted-mode.md](references/scripted-mode.md).

## Reference map

| File                                                       | What's in it                                                         |
| ---------------------------------------------------------- | -------------------------------------------------------------------- |
| [references/setup.md](references/setup.md)                 | Prereqs table, demo-dir staging, trust dialog (shared by both modes) |
| [references/scripted-mode.md](references/scripted-mode.md) | `gen_tape.py` / render / verify / `gen_html.py` detail               |
| [references/live-mode.md](references/live-mode.md)         | tmux + asciinema adaptive loop; Codex + hook-less TUIs               |
| [references/tape-writing.md](references/tape-writing.md)   | Per-agent tape quirks + the sentinel/Stop-hook mechanism             |
| [references/cleanup.md](references/cleanup.md)             | Teardown / garbage collection                                        |

## Scripts

| Script                     | Purpose                                                 |
| -------------------------- | ------------------------------------------------------- |
| `scripts/gen_tape.py`      | Prompt list → full VHS tape (per-agent quirks baked in) |
| `scripts/gen_html.py`      | GIF/MP4/`.cast` → self-contained offline HTML player    |
| `scripts/vhs_stop_hook.sh` | Stop hook emitting the `VHS_TURN_DONE_N` sentinel       |
| `scripts/cleanup.sh`       | Teardown: kill tmux/vhs/ttyd trees, reap counter files  |
