# Teardown / garbage collection

The skill only ever *creates* things; nothing self-cleans. `scripts/cleanup.sh`
reaps it all. Run it after a render that errored or was interrupted, before
re-recording in the same dir, or whenever a stray `vhs`/`ttyd` lingers.

## What it reaps

- **tmux session** — kills the demo session, pane process trees first (so the
  inner `claude`/`asciinema` die before the session is torn down). Leaves the
  tmux server and your other sessions untouched.
- **Orphaned `vhs` renders** — matched by `vhs …*.tape`, then kills each
  process tree, which takes down the `ttyd` + headless-browser children a
  crashed/Ctrl-C'd render leaves behind.
- **Sentinel counter files** — `vhs-demo-*.count` in `$TMPDIR` (one per inner
  session, never self-deleted; see [tape-writing.md](tape-writing.md)).
- **Demo dir** (opt-in, `--demo DIR`) — safety-gated, see below.

Every kill is best-effort: an already-dead PID isn't a failure; a real
permission failure is counted and reported (`kill FAILED …`), never aborts.
Exit is non-zero only if a kill actually failed.

## Usage

```bash
"$SKILL/scripts/cleanup.sh" --dry-run               # examine first: what would die
"$SKILL/scripts/cleanup.sh"                          # reap processes + counter files
"$SKILL/scripts/cleanup.sh" --demo "$DEMO"           # also remove the demo dir (gated)
"$SKILL/scripts/cleanup.sh" --session myname --demo "$DEMO"
```

| Flag            | Effect                                                        |
| --------------- | ------------------------------------------------------------ |
| `--session NAME`| tmux session to kill (default `vhsdemo`, the live-mode name) |
| `--demo DIR`    | also remove this demo dir (safety-gated)                     |
| `--dry-run`     | report what would be killed/removed, change nothing          |
| `--quiet`       | only print the final summary line                            |

## `--demo` safety gate

Removal proceeds only if `DIR` is under `$TMPDIR`/`/tmp`, **or** it contains
`.claude/settings.json` plus a `.tape`/`.cast` (i.e. really looks staged).
`$HOME` and `/` are refused. Uses `rip` when present, else `rm -rf`.
