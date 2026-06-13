#!/bin/sh
# Stop hook for agent demo recording (Claude Code and Codex CLI).
# Emits an incrementing on-screen sentinel (VHS_TURN_DONE_1, _2, ...) so a
# recorder can wait for a specific turn: Wait+Screen@120s /VHS_TURN_DONE_2/
# Gated on $VHS_DEMO so normal sessions are unaffected.
[ -n "$VHS_DEMO" ] || exit 0

sid=$(jq -r '.session_id // "default"' 2>/dev/null)
sid="${sid:-default}"
f="${TMPDIR:-/tmp}/vhs-demo-${sid}.count"
n=$(( $(cat "$f" 2>/dev/null || echo 0) + 1 ))
echo "$n" > "$f"
printf '{"systemMessage": "VHS_TURN_DONE_%d"}\n' "$n"
