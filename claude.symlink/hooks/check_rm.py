#!/usr/bin/env python3
"""
PreToolUse hook for Bash - Block 'rm' commands and suggest 'rip' instead.
"""

import json
import re
import sys

from ansi import C, Icons


def main():
    try:
        raw_input = sys.stdin.read()
        if not raw_input.strip():
            return

        data = json.loads(raw_input)
        tool_input = data.get("tool_input", {})
        command = tool_input.get("command", "")

        # Check if command uses rm (comprehensive detection)
        # Match: rm, sudo rm, \rm (alias bypass), command rm, etc.
        # At start of command or after command separators (&&, ||, ;, |)
        rm_patterns = [
            r"(?:^|&&|\|\||;|\|)\s*rm\s",  # rm at command position
            r"(?:^|&&|\|\||;|\|)\s*sudo\s+rm\s",  # sudo rm
            r"(?:^|&&|\|\||;|\|)\s*\\rm\s",  # \rm (alias bypass)
            r"(?:^|&&|\|\||;|\|)\s*command\s+rm\s",  # command rm
            r"(?:^|&&|\|\||;|\|)\s*/bin/rm\s",  # /bin/rm (direct path)
            r"(?:^|&&|\|\||;|\|)\s*/usr/bin/rm\s",  # /usr/bin/rm
        ]

        if any(re.search(pattern, command) for pattern in rm_patterns):
            reason = f"{C.BRIGHT_RED}{Icons.LOCK} 請使用 {C.BRIGHT_CYAN}rip{C.BRIGHT_RED} 代替 {C.BRIGHT_YELLOW}rm{C.RESET}"
            response = {"decision": "block", "reason": reason}
            print(json.dumps(response))

    except (json.JSONDecodeError, Exception):
        pass


if __name__ == "__main__":
    main()
