#!/usr/bin/env python3
"""
PreToolUse hook for Read - Check if file exists before reading.
"""

import json
import sys
from pathlib import Path

from ansi import C, Icons


def main():
    try:
        raw_input = sys.stdin.read()
        if not raw_input.strip():
            return

        data = json.loads(raw_input)
        tool_name = data.get("tool_name", "")

        # Only check Read tool
        if tool_name != "Read":
            return

        tool_input = data.get("tool_input", {})
        file_path = tool_input.get("file_path", "")

        if not file_path:
            return

        # Resolve path
        path = Path(file_path).expanduser()

        if not path.exists():
            reason = f"{C.BRIGHT_RED}{Icons.CROSS} 檔案不存在: {C.BRIGHT_YELLOW}{file_path}{C.RESET}"
            response = {"decision": "block", "reason": reason}
            print(json.dumps(response))
            return

        if path.is_dir():
            reason = f"{C.BRIGHT_YELLOW}{Icons.FOLDER} 這是目錄: {C.BRIGHT_CYAN}{file_path}{C.RESET} (用 ls 查看)"
            response = {"decision": "block", "reason": reason}
            print(json.dumps(response))
            return

    except (json.JSONDecodeError, Exception):
        pass


if __name__ == "__main__":
    main()
