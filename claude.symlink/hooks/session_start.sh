#!/usr/bin/env bash
# SessionStart hook - Load project context and set environment.
# Triggers: session start, resume, clear, compact.
# Uses CLAUDE_ENV_FILE to persist environment variables for the session.

set -euo pipefail

# Read JSON from stdin
input=$(cat)
[[ -z "$input" ]] && exit 0

# Parse JSON using jq
cwd=$(echo "$input" | jq -r '.cwd // ""')
source=$(echo "$input" | jq -r '.source // "startup"')

# Get project name from cwd
project_name="${cwd##*/}"
[[ -z "$project_name" ]] && project_name="unknown"

# Write environment variables if env file exists
if [[ -n "${CLAUDE_ENV_FILE:-}" ]]; then
    echo "export PROJECT_NAME='$project_name'" >> "$CLAUDE_ENV_FILE"
    echo "export SESSION_SOURCE='$source'" >> "$CLAUDE_ENV_FILE"
fi

# Output JSON response
echo "{\"continue\":true,\"systemMessage\":\"Success\"}"
