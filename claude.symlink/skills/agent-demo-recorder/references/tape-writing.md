# Tape-writing notes & sentinel mechanism

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
  wrap as HTML video (see [scripted-mode.md](scripted-mode.md)).
- Trust dialog on first run in a new dir: see [setup.md](setup.md).

## Sentinel mechanism (for debugging)

`scripts/vhs_stop_hook.sh` is a Stop hook gated on `$VHS_DEMO` (set by the
tape's `Env` command, inherited by the inner session). It reads `session_id`
from the hook's stdin JSON, increments `${TMPDIR:-/tmp}/vhs-demo-<sid>.count`,
and prints `{"systemMessage": "VHS_TURN_DONE_<n>"}` — Claude Code renders
systemMessage on screen, which is the only thing VHS can wait on (it cannot
watch files or processes). Counter files are per-session so reruns start at 1.
They accumulate one-per-session in `$TMPDIR` and are never self-deleted —
`scripts/cleanup.sh` reaps them (see [cleanup.md](cleanup.md)).
