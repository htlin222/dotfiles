#!/usr/bin/env python3
"""
PreToolUse hook for Bash - Check if file exists before cat/bat commands.
"""

import json
import re
import shlex
import sys
from pathlib import Path

from ansi import C, Icons


def extract_file_path(command: str) -> str | None:
    """Extract file path from cat/bat command."""
    # Pattern to match cat or bat at start or after && ; |
    pattern = r"(?:^|&&|\|\||;|\|)\s*(?:cat|bat)\s+(.+?)(?:\s*(?:&&|\|\||;|\||$))"
    match = re.search(pattern, command)
    if not match:
        return None

    args_str = match.group(1).strip()

    # Parse arguments, skip flags (starting with -)
    try:
        args = shlex.split(args_str)
    except ValueError:
        # If shlex fails, try simple split
        args = args_str.split()

    for arg in args:
        # Skip flags
        if arg.startswith("-"):
            continue
        # Return first non-flag argument as file path
        return arg

    return None


def resolve_path(file_path: str) -> Path:
    """Resolve file path, expanding ~ and making absolute."""
    path = Path(file_path).expanduser()
    if not path.is_absolute():
        # Try to resolve relative to cwd
        path = Path.cwd() / path
    return path


def main():
    try:
        raw_input = sys.stdin.read()
        if not raw_input.strip():
            return

        data = json.loads(raw_input)
        tool_input = data.get("tool_input", {})
        command = tool_input.get("command", "")

        # Check if command uses cat or bat
        if not re.search(r"(?:^|&&|\|\||;|\|)\s*(?:cat|bat)\s+", command):
            return

        file_path = extract_file_path(command)
        if not file_path:
            return

        resolved = resolve_path(file_path)

        if not resolved.exists():
            reason = (
                f"{C.BRIGHT_RED}{Icons.CROSS} 檔案不存在:{C.RESET} "
                f"{C.BRIGHT_YELLOW}{file_path}{C.RESET}\n"
                f"   {C.DIM}{Icons.INFO} 建議先用 {C.BRIGHT_CYAN}ls{C.DIM} 或 "
                f"{C.BRIGHT_CYAN}find{C.DIM} 確認路徑{C.RESET}"
            )
            response = {
                "decision": "block",
                "reason": reason,
            }
            print(json.dumps(response))
            return

    except (json.JSONDecodeError, Exception):
        pass


if __name__ == "__main__":
    main()
