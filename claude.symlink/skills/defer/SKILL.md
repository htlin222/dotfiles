---
name: defer
description: Defer execution of a slash-command or prompt until a timer elapses. Starts a background polling timer that prints "TIMER DONE" on stdout, then executes the deferred prompt. Use when the user types `/defer <duration>: <prompt>` (e.g. `/defer 30 mins: run @plan xxx`), `/defer list`, `/defer cancel <id>`, or asks to delay/queue a one-shot prompt for later in the current session.
allowed-tools: Bash, Read, Write, TaskStop
---

# defer — run a prompt after a timer

Session-scoped deferred execution. Parses `/defer <duration>: <prompt>`, launches a background polling timer that emits `TIMER DONE`, then runs `<prompt>` exactly as if the user just typed it.

NOT cross-session — the timer dies with the Claude Code process. Point users at `/schedule` for anything longer-lived.

## Subcommands

| Form | Action |
| --- | --- |
| `/defer <duration>: <prompt>` | Arm a new timer. |
| `/defer list` | Show pending defers. |
| `/defer cancel <id>` | Cancel one defer. |
| `/defer cancel all` | Cancel every pending defer. |

`<id>` = the background-bash shell id returned at arm time. Cancellation uses **TaskStop** with `task_id=<id>`.

## Argument format

```
/defer <duration>: <deferred prompt>
```

- **Duration**: integer + unit, case-insensitive. Units: `s|sec|secs|second|seconds`, `m|min|mins|minute|minutes`, `h|hr|hrs|hour|hours`. Whitespace optional.
- **Separator**: the first `:` after the duration. Everything after, trimmed, is the prompt. The prompt may contain `:`, `/<cmd>`, `@file`.
- **Reject** with one short error line if: duration ≤ 0, duration > 21600 (6h), non-integer (`1.5h` → suggest `90m`), empty prompt, or shape mismatch. Do not guess.

Informal regex: `^\s*(\d+)\s*([A-Za-z]+)\s*:\s*(\S.*?)\s*$`, unit lower-cased before matching.

## Workflow — arm

1. **Parse** → `duration_seconds`, `deferred_prompt`. Apply rejection rules.
2. **Launch** Bash with `run_in_background: true`, using the polling-timer script in [references/timer-script.md](references/timer-script.md). Capture the returned `<sid>`. Do **not** interpolate the prompt into the script.
3. **Persist** `/tmp/claude-defer-<sid>.txt`:
   ```
   END_TS=<unix_end_time>
   <deferred_prompt verbatim>
   ```
4. **Confirm** with one line: `Deferring for <human_duration> (id <sid>). Will run: <≤80-char prompt summary>`
5. **End the turn.** Do not poll, sleep, or Monitor — the harness re-invokes on completion.

## Workflow — wakeup

The completion notification's `<task-id>` IS the shell id `<sid>`. Use it directly.

1. **Read the bash output** (path is in the notification). Last non-empty line must be `TIMER DONE` AND exit code `0` → proceed. Otherwise → **interrupted** (see [references/edge-cases.md](references/edge-cases.md)).
2. **Read** `/tmp/claude-defer-<sid>.txt`, strip the leading `END_TS=…\n`. If missing/malformed, report and stop.
3. **Announce**: `Timer elapsed. Executing: <summary>`.
4. **Execute** the prompt body exactly as if the user just typed it (leading `/<name>` → Skill; otherwise → normal request).
5. **Clean up**: `rip /tmp/claude-defer-<sid>.txt` (env hook blocks `rm`).

## Workflow — list

Glob `/tmp/claude-defer-*.txt`. For each, parse `END_TS` from line 1, summarize the prompt, render a compact table. Format details in [references/examples.md](references/examples.md#list).

## Workflow — cancel

1. **TaskStop** with `task_id=<sid>`. On error (unknown id), report and stop.
2. `rip /tmp/claude-defer-<sid>.txt`.
3. Print `Cancelled defer <sid>.` End turn. The completion notification will fire and the wakeup handler's interrupted branch will recognise the cancel.

`cancel all` → enumerate sids from the temp-file glob, do the above for each.

## References

- [references/timer-script.md](references/timer-script.md) — the polling-timer bash script (verbatim, do not modify).
- [references/examples.md](references/examples.md) — concrete examples for arm / list / cancel / invalid input.
- [references/edge-cases.md](references/edge-cases.md) — interrupted branch, stale files, concurrency, environmental gotchas.
