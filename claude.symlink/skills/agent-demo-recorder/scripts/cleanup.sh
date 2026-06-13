#!/bin/sh
# Teardown / garbage collection for agent-demo-recorder.
#
# The skill only ever *creates* artifacts; this reaps them. It:
#   1. examines + kills the demo tmux session (pane process trees first, so
#      the inner `claude`/`asciinema` die before the session is torn down),
#   2. kills orphaned `vhs` renders and their child trees (ttyd + the headless
#      browser vhs forks), which a crashed/interrupted render leaves behind,
#   3. reaps per-session sentinel counter files (vhs-demo-<sid>.count),
#   4. optionally removes a staged demo directory (behind a safety gate).
#
# Every kill is best-effort: an already-dead PID or a permission failure is
# counted and reported, never fatal. Use --dry-run first to just examine.
#
# Usage:
#   cleanup.sh [--session NAME] [--demo DIR] [--dry-run] [--quiet]
#
#   --session NAME   tmux session to kill        (default: vhsdemo)
#   --demo DIR       also remove this demo dir   (safety-gated; see below)
#   --dry-run        report what WOULD be killed/removed, change nothing
#   --quiet          only print the final summary line
#
# Safety: --demo DIR is removed only if it is a directory living under
# $TMPDIR or /tmp, OR it contains .claude/settings.json plus a .tape/.cast
# file (i.e. it really looks like a staged demo dir). $HOME, /, and anything
# else are refused. Removal uses `rip` when present, else `rm -rf`.

set -u

SESSION="vhsdemo"
DEMO=""
DRY=0
QUIET=0

while [ $# -gt 0 ]; do
  case "$1" in
    --session) SESSION="${2:-}"; shift 2 ;;
    --demo)    DEMO="${2:-}"; shift 2 ;;
    --dry-run) DRY=1; shift ;;
    --quiet)   QUIET=1; shift ;;
    -h|--help) sed -n '2,30p' "$0"; exit 0 ;;
    *) echo "cleanup.sh: unknown arg: $1" >&2; exit 2 ;;
  esac
done

KILLED=0
FAILED=0
REAPED=0

say() { [ "$QUIET" -eq 1 ] || printf '%s\n' "$*"; }

# describe PID -> "pid command" (best-effort; blank if gone)
describe() { ps -p "$1" -o pid=,command= 2>/dev/null | sed 's/^ *//'; }

# kill_tree PID SIG — kill children depth-first, then PID. Counts outcomes.
kill_tree() {
  _pid="$1"; _sig="${2:-TERM}"
  [ -n "$_pid" ] || return 0
  for _c in $(pgrep -P "$_pid" 2>/dev/null); do
    kill_tree "$_c" "$_sig"
  done
  # already gone? not a failure.
  kill -0 "$_pid" 2>/dev/null || return 0
  if [ "$DRY" -eq 1 ]; then
    say "  would kill: $(describe "$_pid")"
    KILLED=$((KILLED + 1))
    return 0
  fi
  if kill -"$_sig" "$_pid" 2>/dev/null; then
    KILLED=$((KILLED + 1))
  else
    FAILED=$((FAILED + 1))
    say "  kill FAILED (pid $_pid still up): $(describe "$_pid")"
  fi
}

# ---- 1. tmux session -------------------------------------------------------
if command -v tmux >/dev/null 2>&1 && tmux has-session -t "$SESSION" 2>/dev/null; then
  say "tmux session '$SESSION': found, tearing down"
  for _p in $(tmux list-panes -t "$SESSION" -F '#{pane_pid}' 2>/dev/null); do
    kill_tree "$_p" TERM
  done
  if [ "$DRY" -eq 1 ]; then
    say "  would kill-session $SESSION"
  elif tmux kill-session -t "$SESSION" 2>/dev/null; then
    say "  session killed"
  else
    say "  session already gone"
  fi
else
  say "tmux session '$SESSION': none"
fi

# ---- 2. orphaned vhs renders (and their ttyd/browser children) -------------
# Match `vhs <something>.tape` so we never hit an editor or this script.
VHS_PIDS=$(pgrep -f 'vhs[^ ]* [^ ]*\.tape' 2>/dev/null || true)
if [ -n "$VHS_PIDS" ]; then
  say "orphaned vhs render(s): $(echo "$VHS_PIDS" | tr '\n' ' ')"
  for _p in $VHS_PIDS; do
    kill_tree "$_p" TERM
  done
else
  say "orphaned vhs render(s): none"
fi

# ---- 3. sentinel counter files --------------------------------------------
for _f in "${TMPDIR:-/tmp}"/vhs-demo-*.count; do
  [ -e "$_f" ] || continue   # glob didn't match -> literal pattern, skip
  if [ "$DRY" -eq 1 ]; then
    say "would reap: $_f"
  else
    rm -f "$_f" 2>/dev/null && REAPED=$((REAPED + 1))
  fi
done
say "counter files reaped: $REAPED"

# ---- 4. demo directory (safety-gated) -------------------------------------
if [ -n "$DEMO" ]; then
  _abs=$(cd "$DEMO" 2>/dev/null && pwd)
  _tmp="${TMPDIR:-/tmp}"
  if [ -z "$_abs" ] || [ ! -d "$_abs" ]; then
    say "demo dir: '$DEMO' is not a directory — refusing"
  elif [ "$_abs" = "$HOME" ] || [ "$_abs" = "/" ]; then
    say "demo dir: '$_abs' is HOME or / — refusing"
  else
    _safe=0
    case "$_abs/" in
      "$_tmp"/*|/tmp/*) _safe=1 ;;
    esac
    if [ "$_safe" -eq 0 ] \
       && [ -f "$_abs/.claude/settings.json" ] \
       && ls "$_abs"/*.tape "$_abs"/*.cast >/dev/null 2>&1; then
      _safe=1
    fi
    if [ "$_safe" -eq 0 ]; then
      say "demo dir: '$_abs' doesn't look like a staged demo dir (not under"
      say "          \$TMPDIR/tmp and no .claude/settings.json + .tape/.cast) — refusing"
    elif [ "$DRY" -eq 1 ]; then
      say "would remove demo dir: $_abs"
    elif command -v rip >/dev/null 2>&1; then
      rip "$_abs" && say "demo dir removed (rip): $_abs"
    else
      rm -rf "$_abs" && say "demo dir removed (rm -rf): $_abs"
    fi
  fi
fi

# ---- summary ---------------------------------------------------------------
if [ "$DRY" -eq 1 ]; then
  printf 'cleanup (dry-run): %d process(es) would be killed, %d counter file(s) present\n' \
    "$KILLED" "$REAPED"
else
  printf 'cleanup: %d killed, %d failed, %d counter file(s) reaped\n' \
    "$KILLED" "$FAILED" "$REAPED"
fi
[ "$FAILED" -eq 0 ]
