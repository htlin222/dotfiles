#!/usr/bin/env python3
"""
PreToolUse hook for Bash - Block 'rm' commands and suggest 'rip' instead.
"""

import json
import os
import re
import sys
from datetime import datetime


def log_debug(msg: str):
    """Log debug info to file."""
    log_dir = os.path.expanduser("~/.claude/logs")
    os.makedirs(log_dir, exist_ok=True)
    with open(os.path.join(log_dir, "check_rm_debug.log"), "a") as f:
        f.write(f"{datetime.now().isoformat()} - {msg}\n")


def main():
    try:
        raw_input = sys.stdin.read()
        log_debug(f"Raw input: {raw_input[:500]}")

        if not raw_input.strip():
            log_debug("Empty input, returning")
            return

        data = json.loads(raw_input)
        log_debug(f"Parsed data keys: {list(data.keys())}")
        tool_input = data.get("tool_input", {})
        command = tool_input.get("command", "")

        # Check if command uses rm (but not in a string or comment)
        # Match: rm, rm -rf, rm -f, etc. at start or after && ; |
        rm_pattern = r"(?:^|&&|\|\||;|\|)\s*rm\s+"

        if re.search(rm_pattern, command):
            # Block the command
            response = {
                "decision": "block",
                "reason": "🚫 請使用 `rip` 代替 `rm`。rip 會將檔案移到垃圾桶，更安全。",
            }
            print(json.dumps(response))
            return

    except (json.JSONDecodeError, Exception):
        pass


if __name__ == "__main__":
    main()
