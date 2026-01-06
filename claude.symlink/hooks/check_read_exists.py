#!/usr/bin/env python3
"""
PreToolUse hook for Read - Check if file exists before reading.
"""

import json
import sys
from pathlib import Path


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
            response = {
                "decision": "block",
                "reason": f"檔案不存在: {file_path}\n建議先用 Glob 或 ls 確認路徑。",
            }
            print(json.dumps(response))
            return

        if path.is_dir():
            response = {
                "decision": "block",
                "reason": f"這是目錄不是檔案: {file_path}\n請用 ls 或 Bash 查看目錄內容。",
            }
            print(json.dumps(response))
            return

    except (json.JSONDecodeError, Exception):
        pass


if __name__ == "__main__":
    main()
