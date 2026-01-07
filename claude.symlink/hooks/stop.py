#!/usr/bin/env python3
"""
Stop hook - Format files and send notification when Claude finishes.

Features:
1. Format edited files with Biome/Prettier/Ruff (--write mode)
2. Send git status via ntfy
"""

import json
import os
import subprocess
import sys
from datetime import datetime, timedelta

# =============================================================================
# Configuration
# =============================================================================

EDIT_LOG_FILE = os.path.expanduser("~/.claude/logs/edits.jsonl")
SESSION_TIMEOUT_MINUTES = 60  # Only format files edited in last N minutes

# File extension to formatter mapping
FORMATTERS = {
    # Biome
    ".js": ["biome", "format", "--write"],
    ".jsx": ["biome", "format", "--write"],
    ".ts": ["biome", "format", "--write"],
    ".tsx": ["biome", "format", "--write"],
    ".json": ["biome", "format", "--write"],
    ".css": ["biome", "format", "--write"],
    # Prettier
    ".html": ["prettier", "--write"],
    ".md": ["prettier", "--write"],
    ".qmd": ["prettier", "--write"],
    ".mdx": ["prettier", "--write"],
    ".yaml": ["prettier", "--write"],
    ".yml": ["prettier", "--write"],
    ".scss": ["prettier", "--write"],
    ".less": ["prettier", "--write"],
    ".vue": ["prettier", "--write"],
    # Python
    ".py": ["ruff", "format"],
    ".pyi": ["ruff", "format"],
}

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


def get_recent_edited_files() -> set[str]:
    """Get files edited in the current session from edits.jsonl."""
    if not os.path.exists(EDIT_LOG_FILE):
        return set()

    cutoff = datetime.now() - timedelta(minutes=SESSION_TIMEOUT_MINUTES)
    edited_files = set()

    try:
        with open(EDIT_LOG_FILE, encoding="utf-8") as f:
            for line in f:
                try:
                    entry = json.loads(line.strip())
                    timestamp = datetime.fromisoformat(entry.get("timestamp", ""))
                    if timestamp >= cutoff:
                        file_path = entry.get("file", "")
                        if file_path and os.path.exists(file_path):
                            edited_files.add(file_path)
                except (json.JSONDecodeError, ValueError):
                    continue
    except Exception:
        pass

    return edited_files


def format_edited_files(files: set[str]) -> int:
    """Format files using appropriate formatters. Returns count of formatted files."""
    formatted_count = 0

    for file_path in files:
        _, ext = os.path.splitext(file_path)
        formatter_cmd = FORMATTERS.get(ext.lower())

        if formatter_cmd:
            try:
                cmd = formatter_cmd + [file_path]
                result = subprocess.run(
                    cmd,
                    capture_output=True,
                    text=True,
                    timeout=30,
                )
                if result.returncode == 0:
                    formatted_count += 1
                    print(
                        f"✨ Formatted: {os.path.basename(file_path)}", file=sys.stderr
                    )
            except (subprocess.TimeoutExpired, FileNotFoundError):
                pass

    return formatted_count


def format_status_line(line: str) -> str:
    """Convert git status line to emoji format."""
    if len(line) < 3:
        return line
    code = line[:2]
    path = line[3:].rstrip("/")
    filename = os.path.basename(path)
    parent = os.path.basename(os.path.dirname(path))
    display_name = f"{parent}/{filename}" if parent else filename
    emoji = STATUS_EMOJI.get(code, "🪾")
    return f"{emoji} {display_name}"


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

        # Format edited files before notification
        edited_files = get_recent_edited_files()
        if edited_files:
            count = format_edited_files(edited_files)
            if count > 0:
                print(f"📝 Formatted {count} files on stop", file=sys.stderr)

        get_git_status_and_notify(cwd, folder_name)

    except json.JSONDecodeError:
        subprocess.run(
            ["ntfy", "publish", "lizard", "Claude Code 對話結束"], check=False
        )
    except Exception:
        pass


if __name__ == "__main__":
    main()
