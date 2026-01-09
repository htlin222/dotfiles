#!/usr/bin/env python3
"""
PostCompact hook - Re-inject CLAUDE.md files after context compaction.
Ensures instructions persist across compaction events.
"""

import os
import sys
from pathlib import Path
from typing import Optional


def get_claude_md_content(file_path: Path) -> Optional[str]:
    """Read CLAUDE.md content if file exists."""
    if file_path.exists() and file_path.is_file():
        try:
            return file_path.read_text(encoding="utf-8")
        except Exception:
            return None
    return None


def main():
    output_parts = []

    # 1. Global CLAUDE.md from ~/.claude/
    global_claude_md = Path.home() / ".claude" / "CLAUDE.md"
    global_content = get_claude_md_content(global_claude_md)
    if global_content:
        output_parts.append(
            f"# Global Instructions (~/.claude/CLAUDE.md)\n\n{global_content}"
        )

    # 2. Project CLAUDE.md from current working directory
    cwd = os.environ.get("CWD", os.getcwd())
    project_claude_md = Path(cwd) / "CLAUDE.md"
    project_content = get_claude_md_content(project_claude_md)
    if project_content:
        output_parts.append(
            f"# Project Instructions ({project_claude_md})\n\n{project_content}"
        )

    if output_parts:
        # Output as user message to re-inject into context
        print("\n---\n".join(output_parts))

    sys.exit(0)


if __name__ == "__main__":
    main()
