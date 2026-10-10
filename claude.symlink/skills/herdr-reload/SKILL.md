---
name: herdr-reload
description: Schedules a delayed self-reload of the current herdr pane — after a delay, types a prompt back into this pane and presses Enter to re-wake the idle agent. Use when the user wants to wait/sleep/delay before running something, schedule a follow-up prompt, set a timed reminder or wall-clock trigger, poll again later, or resume a paused workflow without a human in the loop, inside a herdr terminal session.
input:
  arguments:
    - name: delay
      type: string
      description: How long to wait before firing — "30s", "4m", "2h", "1d", a bare number of seconds ("1200"), or "HH:MM" for the next wall-clock occurrence of that time.
      required: true
    - name: prompt
      type: string
      description: The text to type back into this pane after the delay, then Enter is pressed separately. Keep it a single line.
      required: true
---

# herdr-reload

Arms a detached background timer that outlives the current turn (and the
current session, if it exits). When it fires, it types a prompt into THIS
herdr pane and presses Enter — re-prompting whatever agent (Claude Code, a
shell, etc.) is idle there.

Prefer this over `ScheduleWakeup` or a session-bound `CronCreate` job for
"come back and do X later" requests inside a herdr pane: those die if the
session ends, this does not, because it's a `nohup`/`setsid` + `disown`'d
process, not something tracked by the current process.

## Usage

```bash
bash "$SKILL/scripts/reload.sh" <delay> <prompt...>
```

- `<delay>`: `30s`, `4m`, `2h`, `1d`, a bare number of seconds (`1200`), or
  `HH:MM` for the next wall-clock occurrence of that time (24h, rolls to
  tomorrow if already past today).
- `<prompt...>`: the text to type back into this pane after the delay. Keep
  it a single line — it's typed literally, then Enter is pressed separately.

Examples:

```bash
bash "$SKILL/scripts/reload.sh" 3h "處理過去6小時的 issues"
bash "$SKILL/scripts/reload.sh" 1200s "check the deploy status again"
bash "$SKILL/scripts/reload.sh" 09:30 "start the morning standup summary"
```

Run it and report the confirmation line back to the user (pane id, resolved
seconds, prompt) — don't just say "done" silently, the exact fire time is
useful to them.

## How it resolves "this pane"

It reads `$HERDR_PANE_ID` if set, otherwise calls `herdr pane current` and
parses the pane id from the JSON. This means it always targets the pane the
calling shell is actually running in — no session id or pane id needs to be
passed manually.

## Notes

- Requires `herdr` and `python3` on `PATH`.
- The worker's stdout/stderr is appended to `${TMPDIR:-/tmp}/herdr-reload.log`
  — check there if a scheduled reload doesn't seem to have fired.
- Each call arms one independent timer; calling it multiple times stacks
  multiple pending reloads, it doesn't replace a prior one.
- There's no cancel — a scheduled reload can only be prevented by killing the
  detached `bash` process running the `sleep`, found via `pgrep -fl reload.sh`
  or by process start time in `ps`.
