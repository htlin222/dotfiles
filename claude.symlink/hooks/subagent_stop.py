#!/usr/bin/env python3
"""
SubagentStop hook - Notify when a subagent (Task tool) completes.

Features:
1. TTS notification (async, non-blocking)
2. Log subagent completion for tracking
"""

import json
import os
import subprocess
import sys
from datetime import datetime

LOG_DIR = os.path.expanduser("~/.claude/logs")
SUBAGENT_LOG_FILE = os.path.join(LOG_DIR, "subagents.jsonl")


def log_subagent_completion(session_id: str, cwd: str):
    """Log subagent completion."""
    os.makedirs(LOG_DIR, exist_ok=True)

    entry = {
        "timestamp": datetime.now().isoformat(),
        "session_id": session_id,
        "project": os.path.basename(cwd) if cwd else "",
    }

    try:
        with open(SUBAGENT_LOG_FILE, "a", encoding="utf-8") as f:
            f.write(json.dumps(entry, ensure_ascii=False) + "\n")
    except Exception:
        pass


def main():
    try:
        raw_input = sys.stdin.read()
        if not raw_input.strip():
            return

        data = json.loads(raw_input)
        session_id = data.get("session_id", "")
        cwd = data.get("cwd", "")

        # Log completion
        log_subagent_completion(session_id, cwd)

        # TTS notification (async with &, fire and forget)
        # This runs in background so it doesn't block
        subprocess.Popen(
            ["say", "-v", "Samantha", "Subagent complete"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )

    except (json.JSONDecodeError, Exception):
        pass


if __name__ == "__main__":
    main()
