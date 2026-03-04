# session-hint hook

Runs on every `SessionStart` event. Handles per-session state management and startup messages.

## What it does

1. **Tmux busy status** — Sets the current pane to idle and cleans up stale busy markers.
2. **State reset** — On `startup` or `clear`, resets hook state and records the main session ID (so delegate-edits can detect the main session).
3. **Session start time** — Writes a Unix timestamp to `/tmp/claude_session_start_time` so shell scripts can determine when the session began.
4. **Startup messages** — Builds context-aware hints (delegation mode, @LAST availability, Qing mode).

## Tmp files

### Global: `/tmp/claude_session_start_time`

Always written. If multiple sessions run in parallel, the last one to start wins.

### Pane-specific: `/tmp/claude_session_start_time_pane_<N>`

Written when `$TMUX_PANE` is set (e.g., pane `%134` → `_pane_134`). Safe for parallel sessions in different tmux panes.

- **Format**: Unix timestamp (seconds since epoch), followed by a newline
- **Updated**: Every `SessionStart` event (`startup`, `clear`, `resume`, `compact`)
- **Usage**:
  ```bash
  # Global (single session)
  cat /tmp/claude_session_start_time

  # Pane-specific (parallel sessions)
  cat /tmp/claude_session_start_time_pane_${TMUX_PANE#%}
  ```

## SessionStart sources

| Source    | State reset | Timestamp written |
|-----------|-------------|-------------------|
| `startup` | Yes         | Yes               |
| `clear`   | Yes         | Yes               |
| `resume`  | No          | Yes               |
| `compact` | No          | Yes               |
