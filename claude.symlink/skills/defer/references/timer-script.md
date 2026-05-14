# Polling-timer script

Use this script verbatim in the Bash tool call with `run_in_background: true`. Substitute `<N>` with the integer `duration_seconds`. **Never** interpolate the user's prompt into this script — the prompt lives in `/tmp/claude-defer-<sid>.txt`, this script only does timing.

```bash
END=$(( $(date +%s) + <N> ))
while [ "$(date +%s)" -lt "$END" ]; do
  REMAIN=$(( END - $(date +%s) ))
  printf '[defer] %ss remaining\n' "$REMAIN"
  if   [ "$REMAIN" -gt 600 ]; then sleep 60
  elif [ "$REMAIN" -gt 60  ]; then sleep 15
  else                              sleep 5
  fi
done
echo "TIMER DONE"
```

## Why this shape

- **Polling loop** (per the original requirement) — checks the wall clock each tick rather than blocking on one big `sleep`. Lets the script emit progress lines the user can inspect via `Read` on the bash output file.
- **Adaptive sleep cadence** (60 s / 15 s / 5 s) keeps it responsive near the deadline without flooding the harness for multi-hour defers. A 6 h timer emits at most ~360 progress lines; a 30 s timer emits ~6.
- **Final `echo "TIMER DONE"`** is the sentinel the wakeup handler grep-matches on. Any other terminal state (cancelled, killed, exited early) means the script did not reach this line, so the handler can distinguish completion from interruption purely from the bash output.
- **No `rm`/`unlink`** inside the script — cleanup is the agent's job after wakeup. Keeps the script identical regardless of env hooks.
- **No prompt interpolation** — eliminates the entire class of shell-injection concerns from user-supplied prompts containing `;`, `$(…)`, backticks, etc.

## Cancellation

Use the **TaskStop** tool with `task_id=<sid>`. The script does not check a sentinel file — `TaskStop` terminates the bash directly, which is faster (no tick-wait) and avoids extra state.

When `TaskStop` kills the process mid-loop, the bash output file will end with the last `[defer] Ns remaining` line, not `TIMER DONE`. The wakeup handler keys off that to recognise a cancellation.
