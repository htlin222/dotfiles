#!/usr/bin/env python3
"""
PreToolUse hook for Bash - Block 'rm' commands and suggest 'rip' instead.
"""

import json
import re
import sys


def main():
    try:
        raw_input = sys.stdin.read()
        if not raw_input.strip():
            return

        data = json.loads(raw_input)
        tool_input = data.get("tool_input", {})
        command = tool_input.get("command", "")

        # Check if command uses rm (but not in a string or comment)
        # Match: rm, rm -rf, rm -f, etc. at start or after && ; |
        rm_pattern = r"(?:^|&&|\|\||;|\|)\s*rm\s+"

        if re.search(rm_pattern, command):
            response = {
                "decision": "block",
                "reason": "🚫 請使用 `rip` 代替 `rm`。rip 會將檔案移到垃圾桶，更安全。",
            }
            print(json.dumps(response))

    except (json.JSONDecodeError, Exception):
        pass


if __name__ == "__main__":
    main()
