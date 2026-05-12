#!/usr/bin/env bash
# Convenience wrapper that auto-installs Python deps via uv.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
exec uv run --quiet --with wasmtime --with httpx python3 "$HERE/client.py" "$@"
