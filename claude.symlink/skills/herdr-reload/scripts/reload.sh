#!/usr/bin/env bash
# reload.sh — schedule a detached self-reload of the current herdr pane.
#
# Usage:  reload.sh <delay> <prompt...>
#
#   <delay>   30s | 4m | 2h | 1d | 90 (bare = seconds) | HH:MM (next wall-clock time)
#   <prompt>  the text to type back into THIS pane after the delay (keep it single line)
#
# After <delay>, the detached worker types <prompt> into the pane and presses Enter,
# re-prompting whatever agent (Claude Code, a shell, etc.) is idle there.
set -euo pipefail

die() { printf 'reload: %s\n' "$*" >&2; exit 1; }

[[ $# -ge 2 ]] || die "usage: reload.sh <delay> <prompt...>"

raw_delay="$1"; shift
prompt="$*"

command -v herdr >/dev/null 2>&1 || die "herdr CLI not found on PATH"

# --- resolve this pane -------------------------------------------------------
pane="${HERDR_PANE_ID:-}"
if [[ -z "$pane" ]]; then
  pane="$(herdr pane current 2>/dev/null \
    | python3 -c 'import sys,json;print(json.load(sys.stdin)["result"]["pane"]["pane_id"])' 2>/dev/null || true)"
fi
[[ -n "$pane" ]] || die "not inside a herdr pane (HERDR_PANE_ID unset and 'herdr pane current' failed)"

# --- parse the delay into seconds -------------------------------------------
parse_delay() {
  local r="$1" n u
  if [[ "$r" =~ ^([0-9]+)$ ]]; then echo "${BASH_REMATCH[1]}"; return 0; fi
  if [[ "$r" =~ ^([0-9]+)([smhd])$ ]]; then
    n="${BASH_REMATCH[1]}"; u="${BASH_REMATCH[2]}"
    case "$u" in
      s) echo "$n" ;;
      m) echo $((n * 60)) ;;
      h) echo $((n * 3600)) ;;
      d) echo $((n * 86400)) ;;
    esac
    return 0
  fi
  if [[ "$r" =~ ^([0-9]{1,2}):([0-9]{2})$ ]]; then
    python3 - "$r" <<'PY'
import sys, datetime
hh, mm = map(int, sys.argv[1].split(":"))
if hh > 23 or mm > 59:
    sys.exit(1)
now = datetime.datetime.now()
t = now.replace(hour=hh, minute=mm, second=0, microsecond=0)
if t <= now:
    t += datetime.timedelta(days=1)
print(int((t - now).total_seconds()))
PY
    return 0
  fi
  return 1
}

secs="$(parse_delay "$raw_delay")" \
  || die "bad delay '$raw_delay' (use e.g. 30s, 4m, 2h, 1d, 90, or HH:MM)"
[[ "$secs" -gt 0 ]] || die "delay resolved to $secs seconds — nothing to wait for"

# --- fire a fully-detached worker and return immediately --------------------
log="${TMPDIR:-/tmp}/herdr-reload.log"
export _RL_PANE="$pane" _RL_SECS="$secs" _RL_PROMPT="$prompt"

# shellcheck disable=SC2016  # vars are expanded by the child shell from the
# exported environment on purpose — avoids re-quoting the prompt.
worker='
  sleep "$_RL_SECS"
  herdr pane send-text "$_RL_PANE" "$_RL_PROMPT"
  sleep 0.4
  herdr pane send-keys "$_RL_PANE" enter
'

# Detach so the timer outlives this shell / the agent turn.
# setsid exists on Linux; macOS has none, so fall back to nohup + disown.
if command -v setsid >/dev/null 2>&1; then
  setsid bash -c "$worker" >>"$log" 2>&1 &
else
  nohup bash -c "$worker" >>"$log" 2>&1 &
fi
disown 2>/dev/null || true

printf 'reload scheduled: pane %s in %ss → %s\n' "$pane" "$secs" "$prompt"
