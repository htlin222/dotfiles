#!/usr/bin/env bash
# codex-imagegen: generate an image via the Codex CLI's image generation tool
# and save it to a file. Auth is the user's existing ChatGPT login (codex login),
# no OPENAI_API_KEY required.
#
# Usage:
#   imagegen.sh <output-path> <description...>
#
# Example:
#   imagegen.sh tmp/shiba.png 戴墨鏡的柴犬
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "usage: $(basename "$0") <output-path> <description...>" >&2
  exit 2
fi

out="$1"; shift
desc="$*"

if ! command -v codex >/dev/null 2>&1; then
  echo "error: codex CLI not found. Install with 'brew install --cask codex' or 'npm i -g @openai/codex'." >&2
  exit 127
fi

if ! codex login status 2>&1 | grep -q "Logged in"; then
  echo "error: codex is not logged in. Run 'codex login' first." >&2
  exit 1
fi

if [[ -z "${OPENAI_API_KEY:-}" ]]; then
  echo "warn: OPENAI_API_KEY is not set. The codex agent in this env tends to call the OpenAI" >&2
  echo "      images API directly with that key; without it the agent may fail to write the file." >&2
fi

# Resolve absolute path so codex (running with -C cwd) writes where we expect,
# and so we can verify it afterwards regardless of how codex resolved relatives.
case "$out" in
  /*) abs_out="$out" ;;
  *)  abs_out="$(pwd)/$out" ;;
esac
mkdir -p "$(dirname "$abs_out")"

prompt="請使用 image generation tool 生成一張圖：${desc}。將結果存成 ${abs_out}，不要做其他事。"

# When run from inside Claude Code (or any host with the Codex Companion plugin),
# the shell inherits CODEX_COMPANION_SESSION_ID / CLAUDE_PLUGIN_DATA. The companion
# then hijacks `codex exec` and routes it back into the existing companion session
# (which replaces our prompt). Unset them so this exec starts a fresh codex run.
env -u CODEX_COMPANION_SESSION_ID -u CLAUDE_PLUGIN_DATA \
  codex exec \
    -C "$(pwd)" \
    --dangerously-bypass-approvals-and-sandbox \
    --skip-git-repo-check \
    "$prompt"

if [[ ! -s "$abs_out" ]]; then
  echo "error: codex finished but no file was written to ${abs_out}" >&2
  exit 1
fi

bytes=$(wc -c <"$abs_out" | tr -d ' ')
echo "wrote ${abs_out} (${bytes} bytes)"
