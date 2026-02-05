#!/usr/bin/env bash
# title: self_test
# description: Basic cross-platform checks for dotfile helper functions

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

echo "== self_test: lib helpers =="

echo "- OS: $(uname -s)"

echo "- notify: "
if notify "dotfiles self-test" "hello from notify()" 2>/dev/null; then
  echo "  ok (notification sent if supported)"
else
  echo "  ok (no notifier available)"
fi

echo "- open_cmd: "
if open_cmd "$SCRIPT_DIR" >/dev/null 2>&1; then
  echo "  ok (opened current script dir)"
else
  echo "  warn (no open command available)"
fi

echo "- clipboard copy/paste: "
if command -v pbcopy >/dev/null 2>&1 || command -v wl-copy >/dev/null 2>&1 || command -v xclip >/dev/null 2>&1 || command -v xsel >/dev/null 2>&1; then
  echo "  ok (copy command available)"
else
  echo "  warn (no clipboard copy tool found)"
fi

if command -v pbpaste >/dev/null 2>&1 || command -v wl-paste >/dev/null 2>&1 || command -v xclip >/dev/null 2>&1 || command -v xsel >/dev/null 2>&1; then
  echo "  ok (paste command available)"
else
  echo "  warn (no clipboard paste tool found)"
fi

echo "== self_test complete =="
