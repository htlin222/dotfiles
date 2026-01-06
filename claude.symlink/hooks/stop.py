#!/usr/bin/env python3
"""
Stop hook - Send notification when Claude finishes.
Sends git status via ntfy.
"""

import json
import os
import subprocess
import sys

STATUS_EMOJI = {
    "??": "❓",  # Untracked
    " A": "➕",  # Added to staging
    "A ": "➕",  # Added to staging
    " M": "📝",  # Modified (not staged)
    "M ": "✏️",  # Modified and staged
    "MM": "✏️",  # Modified, staged, then modified again
    "AM": "🆕",  # Added, then modified
    " D": "🗑️",  # Deleted (not staged)
    "D ": "🗑️",  # Deleted and staged
    "R ": "📛",  # Renamed
    "C ": "📋",  # Copied
    "U ": "⚠️",  # Unmerged
}


def format_status_line(line: str) -> str:
    """Convert git status line to emoji format."""
    if len(line) < 3:
        return line
    code = line[:2]
    path = line[3:]
    filename = os.path.basename(path.rstrip("/"))
    emoji = STATUS_EMOJI.get(code, "🪾")
    return f"{emoji} {filename}"


def get_git_status_and_notify(cwd: str, folder_name: str) -> None:
    """Get git status and send ntfy notification."""
    title = f"Claude Code 📁 {folder_name}" if folder_name else "Claude Code"

    try:
        git_result = subprocess.run(
            ["git", "status", "-s"],
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=10,
        )
        git_status = git_result.stdout.strip()

        if git_status:
            lines = git_status.split("\n")
            formatted = [format_status_line(line) for line in lines]
            body = "\n".join(formatted)
        else:
            body = "無 Git 變動"

        subprocess.run(
            ["ntfy", "publish", "--title", title, "lizard", body],
            check=False,
        )

    except Exception:
        subprocess.run(
            ["ntfy", "publish", "--title", title, "lizard", "對話已完成"],
            check=False,
        )


def main():
    try:
        raw_input = sys.stdin.read()

        if not raw_input.strip():
            subprocess.run(
                ["ntfy", "publish", "lizard", "Claude Code 對話結束"], check=False
            )
            return

        data = json.loads(raw_input)
        cwd = data.get("cwd", "")
        folder_name = os.path.basename(cwd) if cwd else ""

        get_git_status_and_notify(cwd, folder_name)

    except json.JSONDecodeError:
        subprocess.run(
            ["ntfy", "publish", "lizard", "Claude Code 對話結束"], check=False
        )
    except Exception:
        pass


if __name__ == "__main__":
    main()
