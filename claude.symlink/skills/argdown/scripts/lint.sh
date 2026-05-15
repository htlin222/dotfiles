#!/usr/bin/env bash
# Fail-fast Argdown linter: exits non-zero on any parser error so it
# can drive an iterate-until-clean loop. Wraps `argdown <file>` with
# --throwExceptions so the CLI's default behavior of soft-logging
# becomes a hard failure suitable for scripting.
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: lint.sh <file.argdown>" >&2
  exit 2
fi

file=$1
if [[ ! -f $file ]]; then
  echo "lint.sh: file not found: $file" >&2
  exit 2
fi

if ! command -v argdown >/dev/null 2>&1; then
  echo "lint.sh: argdown CLI not on PATH. Install: npm i -g @argdown/cli" >&2
  exit 127
fi

argdown --throwExceptions "$file"
