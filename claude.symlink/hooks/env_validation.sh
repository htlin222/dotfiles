#!/usr/bin/env bash
# EnvValidation hook - Run validation asynchronously to not block startup.
# Triggers: SessionStart hook.

set -euo pipefail

# Read and store input for the background process
input=$(cat)
[[ -z "$input" ]] && exit 0

# Parse source - only run on startup/clear, not resume/compact
source=$(echo "$input" | jq -r '.source // "startup"')
if [[ "$source" != "startup" && "$source" != "clear" ]]; then
    echo '{"continue":true}'
    exit 0
fi

# Run Python validation in background (non-blocking)
# Write input to temp file for background process
tmpfile=$(mktemp)
echo "$input" > "$tmpfile"
(python3 ~/.claude/hooks/env_validation_worker.py < "$tmpfile"; rm -f "$tmpfile") &
disown

# Return immediately - don't block startup
echo '{"continue":true}'
