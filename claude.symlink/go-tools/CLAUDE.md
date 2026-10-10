# go-tools — Claude Code hook binaries

Go module `github.com/htlin/claude-tools` (Go 1.21). Builds two binaries:

- `claude-hooks` — unified hook runner; `~/.claude/settings.json` wires
  subcommands (`claude-hooks stop`, `claude-hooks user-prompt`, …) to Claude
  Code hook events.
- `claude-statusline` — status bar renderer (tokens, git, CPU/memory).

## Layout

- `cmd/` — main packages (thin dispatchers).
- `internal/hooks/<name>/` — one package per hook subcommand: stop,
  userprompt, posttooluse (format + lint the edited file → additionalContext;
  Bash metrics), fileguard, checkrm, branchguard, delegateedits,
  notification, sessionend, sessionhint, precompact, subagentstop,
  tursosync (spawned internally), depremind, envvalidation,
  checkfileexists (Codex only); plus busy (tmux pane state), killtimer
  (idle auto-kill) and sessiontimer.
- **Shared with Codex CLI** (`~/.codex/config.toml`): check-rm,
  branch-guard, check-file-exists, file-guard (incl. `apply_patch`),
  post-tool-use (Bash only). Output protocol must work for both: allow =
  exit 0 + no stdout; block = `hookSpecificOutput.permissionDecision:"deny"`
  with a non-empty reason (see `internal/protocol/output.go`). No ANSI in
  any JSON hook output (reasons, systemMessage, additionalContext).
- `internal/` support: `config` (paths, embedded formatters.json),
  `protocol` (hook stdin/stdout JSON), `processors` (formatter/linter
  runners), `snapshot` (@LAST context snapshots), `statusline`, `state`,
  `turso` (libSQL sync of prompts.db).
- `pkg/` reusable: `notify` (macOS banner + ntfy push + TTS sequencing),
  `elevenlabs`, `groq` (TLDR summaries), `ansi`, `dotenv`, `metrics`,
  `patterns` (risky-command/sensitive-file detection), `context`.

## Workflow

```sh
make build      # both binaries, stripped
make install    # build + copy to ~/.local/bin  ← required for changes to take effect
make test       # go test -v ./...
make lint       # golangci-lint || go vet
```

Hooks run from `~/.local/bin`, **not** from this repo — editing Go code does
nothing until `make install`.

## Tests

Table-driven, colocated `*_test.go`. Single package:
`go test -v ./internal/hooks/stop`. Network clients (elevenlabs, groq, ntfy,
turso) gate live tests behind `*_LIVE_TEST` env vars — skipped by default.

## Env / secrets

Read via `pkg/dotenv` (env var, falling back to gitignored `.env`; see
`.env.example`): `GROQ_API_KEY`, `ELEVENLABS_API_KEY` (+ voice/model
overrides), `NTFY_TOPIC`, `TURSO_DATABASE_URL`/`TURSO_AUTH_TOKEN`.
Behavior toggles: `CLAUDE_STOP_AND_KILL`, `FORCE_DELEGATION`.
Logs land in `~/.claude/logs/*.jsonl` (metrics, events, edits, sessions);
`metrics.AppendJSONL` rotates any log >10MB to `<name>.1`. `prompts.jsonl`
(prompt history) is deliberately never rotated.
