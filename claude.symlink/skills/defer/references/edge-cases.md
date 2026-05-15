# Edge cases & robustness

## Interrupted branch (wakeup, but not `TIMER DONE`)

When the bash output's last non-empty line is **not** `TIMER DONE`, or the exit code is non-zero:

1. Print one line summarizing what happened, e.g.
   - `Defer <sid> was cancelled before completion.` (TaskStop case — typical exit when the process is SIGTERM'd mid-loop)
   - `Defer <sid> exited with code N — last output: <last line>.`
2. `rip /tmp/claude-defer-<sid>.txt`.
3. **Do not auto-execute** the deferred prompt. If the user wants it run anyway, they'll say so.

Common reasons for an interrupted exit:
- User ran `/defer cancel <sid>`.
- User ran `/defer cancel all`.
- The Claude Code process was suspended and the bash got SIGKILL'd by the OS.
- Disk full / process limit / other env failure (rare; surface the last line).

## Stale temp files

If a previous Claude Code session crashed, its `/tmp/claude-defer-*.txt` files may linger. They're harmless but visible in `/defer list`. Detection: the corresponding background task is no longer alive. `/defer list` should flag those as `(stale)` and offer:

```
You:  3 stale defer files found. rip them? (yes/no)
```

On `yes`: `rip /tmp/claude-defer-*.txt` filtered to just the stale ones.

## Concurrency

- **Multiple active defers** are fine — each has its own `<sid>` and its own state file. The wakeup notification's `<task-id>` disambiguates which one fired.
- **Defers that arm more defers**: allowed. A deferred prompt can be `/defer 5m: /defer 5m: foo` — nesting works because each defer is independent.
- **Same prompt deferred twice**: also fine; they run independently and each consumes its own state file.

## Environmental gotchas

- **`rm` is hook-blocked** in this user's env (`⊘ 請使用 rip 代替 rm`). Use `rip` for all agent-side cleanup. Do not use `rm`, `unlink`, or any wrapper that the hook might still match — `rip` is the sanctioned path.
- **No prompt interpolation into the bash script.** The script is fixed; the prompt is data in a file. This eliminates shell-injection from prompts containing `;`, `$()`, backticks, newlines, etc.
- **Clock skew** between successive `date +%s` calls within the loop is bounded to ~1 s, well below the smallest poll interval (5 s). Immaterial.
- **Process exits kill the timer.** Session-scoped is intentional. If the user wants persistence across `claude` restarts, redirect them to `/schedule`.
- **macOS Bash 3.2** is the default shell on macOS — the script uses only POSIX features (`[ … ]`, `printf`, `sleep`, `$(( … ))`, `$(…)`), so it works on Bash 3.2 and any modern `/bin/sh`.

## Cap rationale

`21600 s` (6 h) is an arbitrary upper bound chosen so that a forgotten defer cannot tie up a background slot indefinitely. Anything longer is a strong signal the user wants cross-session persistence — that's what `/schedule` is for. If the user genuinely needs a 12 h in-session defer, they can chain (`/defer 6h: /defer 6h: foo`), but suggest `/schedule` first.

## Bash output file format

Each line in the bash output file looks like:

```
[defer] 1799s remaining
[defer] 1739s remaining
…
[defer] 5s remaining
TIMER DONE
```

The wakeup handler should:
- Read the whole file (it's small — at most a few hundred lines).
- Find the last non-empty line.
- Match exactly `TIMER DONE` (no trailing whitespace, no ANSI codes — `printf` and `echo` don't emit any here).

If the file has trailing terminal-control bytes from the harness wrapper (rare), strip them before matching.
