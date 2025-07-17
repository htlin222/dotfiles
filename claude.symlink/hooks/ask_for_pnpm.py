#!/usr/bin/env python3
import json
import re
import sys


def main():
    try:
        data = json.load(sys.stdin)
    except Exception as e:
        sys.stderr.write(f"Invalid JSON input: {e}")
        sys.exit(1)

    tool = data.get("tool_name")
    cmd = data.get("tool_input", {}).get("command", "")
    # 只有在 Bash 執行 npm 指令時攔截
    if tool == "Bash" and re.match(r"^npm\s", cmd):
        sys.stderr.write("偵測到 npm 指令。你要使用 npm 還是 pnpm？\n")
        sys.exit(2)  # exit code 2 => block with stderr to Claude
    # 其他指令通過
    sys.exit(0)


if __name__ == "__main__":
    main()
