#!/usr/bin/env python3
"""
SubagentStop hook - Notify when a subagent (Task tool) completes.

Features:
1. TTS notification (async, non-blocking)
2. Log subagent completion for tracking
3. Hook metrics logging
"""

import json
import os
import sys
import time
from datetime import datetime

# Import TTS utility
from tts import notify_subagent_complete
from metrics import log_hook_metrics, log_hook_event

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
    start_time = time.time()
    try:
        raw_input = sys.stdin.read()
        if not raw_input.strip():
            return

        data = json.loads(raw_input)
        session_id = data.get("session_id", "")
        cwd = data.get("cwd", "")
        project_name = os.path.basename(cwd) if cwd else ""

        # Log completion
        log_subagent_completion(session_id, cwd)

        # TTS notification with project name
        notify_subagent_complete(project_name)

        # Log metrics
        execution_time_ms = (time.time() - start_time) * 1000
        log_hook_metrics(
            hook_name="subagent_stop",
            event_type="SubagentStop",
            execution_time_ms=execution_time_ms,
            session_id=session_id,
            success=True,
            metadata={"project": project_name},
        )

        log_hook_event(
            event_type="SubagentStop",
            hook_name="subagent_stop",
            session_id=session_id,
            cwd=cwd,
            metadata={"project": project_name},
        )

    except (json.JSONDecodeError, Exception):
        pass


if __name__ == "__main__":
    main()
