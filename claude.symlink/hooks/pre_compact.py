#!/usr/bin/env python3
"""
PreCompact hook - Save context state before compaction.
Triggers: before Claude Code compacts conversation context.

Features:
1. Save current dev-docs state
2. Log important context to recover later
3. Create checkpoint of conversation summary
"""

import json
import os
import sys
import time
from datetime import datetime
from pathlib import Path

# Import TTS utility
from tts import notify_compact
from metrics import log_hook_metrics, log_hook_event

# =============================================================================
# Configuration
# =============================================================================

LOG_DIR = os.path.expanduser("~/.claude/logs")
CONTEXT_DIR = os.path.expanduser("~/.claude/context-snapshots")


def save_context_snapshot(cwd: str, transcript_path: str, session_id: str):
    """Save context snapshot before compaction."""
    os.makedirs(CONTEXT_DIR, exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    project_name = os.path.basename(cwd) if cwd else "unknown"

    snapshot = {
        "timestamp": datetime.now().isoformat(),
        "session_id": session_id,
        "project": project_name,
        "cwd": cwd,
        "transcript_path": transcript_path,
        "dev_docs": {},
        "git_status": "",
        "active_todos": [],
    }

    # Capture dev docs if they exist
    dev_docs_dir = Path(cwd) / "dev" / "active" if cwd else None
    if dev_docs_dir and dev_docs_dir.exists():
        for task_dir in dev_docs_dir.iterdir():
            if task_dir.is_dir():
                task_docs = {}
                for doc_file in ["plan.md", "context.md", "tasks.md"]:
                    doc_path = task_dir / doc_file
                    if doc_path.exists():
                        try:
                            task_docs[doc_file] = doc_path.read_text(encoding="utf-8")[
                                :5000
                            ]
                        except Exception:
                            pass
                if task_docs:
                    snapshot["dev_docs"][task_dir.name] = task_docs

    # Capture git status summary
    if cwd:
        try:
            import subprocess

            result = subprocess.run(
                ["git", "status", "--short"],
                cwd=cwd,
                capture_output=True,
                text=True,
                timeout=5,
            )
            if result.returncode == 0:
                snapshot["git_status"] = result.stdout[:1000]
        except Exception:
            pass

    # Extract last messages from transcript
    if transcript_path and os.path.exists(transcript_path):
        try:
            with open(transcript_path, "r", encoding="utf-8") as f:
                lines = f.readlines()[-30:]

            messages = []
            for line in lines:
                try:
                    entry = json.loads(line.strip())
                    if isinstance(entry, dict) and entry.get("role") in (
                        "user",
                        "assistant",
                    ):
                        content = entry.get("content", "")
                        if isinstance(content, str):
                            text = content[:200]
                        elif isinstance(content, list):
                            for item in content:
                                if (
                                    isinstance(item, dict)
                                    and item.get("type") == "text"
                                ):
                                    text = item.get("text", "")[:200]
                                    break
                            else:
                                text = ""
                        else:
                            text = ""
                        if text:
                            messages.append({"role": entry.get("role"), "text": text})
                except json.JSONDecodeError:
                    continue

            snapshot["recent_messages"] = messages[-10:]
        except Exception:
            pass

    # Save snapshot
    snapshot_file = os.path.join(CONTEXT_DIR, f"{project_name}_{timestamp}.json")
    with open(snapshot_file, "w", encoding="utf-8") as f:
        json.dump(snapshot, f, indent=2, ensure_ascii=False)

    # Keep only last 20 snapshots
    cleanup_old_snapshots()

    return snapshot_file


def cleanup_old_snapshots():
    """Remove old snapshots, keeping only the last 20."""
    try:
        snapshots = sorted(Path(CONTEXT_DIR).glob("*.json"), key=os.path.getmtime)
        for old_snapshot in snapshots[:-20]:
            old_snapshot.unlink()
    except Exception:
        pass


def main():
    start_time = time.time()
    try:
        raw_input = sys.stdin.read()
        if not raw_input.strip():
            return

        data = json.loads(raw_input)
        cwd = data.get("cwd", "")
        transcript_path = data.get("transcript_path", "")
        session_id = data.get("session_id", "")

        # Save context snapshot
        snapshot_file = save_context_snapshot(cwd, transcript_path, session_id)
        project_name = os.path.basename(cwd) if cwd else ""

        # TTS notification
        notify_compact(project_name)

        # Log the compaction event
        os.makedirs(LOG_DIR, exist_ok=True)
        log_file = os.path.join(LOG_DIR, "compactions.jsonl")
        log_entry = {
            "timestamp": datetime.now().isoformat(),
            "cwd": cwd,
            "snapshot_file": snapshot_file,
        }
        with open(log_file, "a", encoding="utf-8") as f:
            f.write(json.dumps(log_entry, ensure_ascii=False) + "\n")

        # Log metrics
        execution_time_ms = (time.time() - start_time) * 1000
        log_hook_metrics(
            hook_name="pre_compact",
            event_type="PreCompact",
            execution_time_ms=execution_time_ms,
            session_id=session_id,
            success=True,
            metadata={
                "project": project_name,
                "snapshot_file": os.path.basename(snapshot_file) if snapshot_file else None,
            },
        )

        log_hook_event(
            event_type="PreCompact",
            hook_name="pre_compact",
            session_id=session_id,
            cwd=cwd,
            metadata={"snapshot_file": snapshot_file},
        )

        # Return message to Claude
        response = {
            "continue": True,
            "systemMessage": f"📸 Context snapshot saved before compaction: {os.path.basename(snapshot_file)}",
        }
        print(json.dumps(response))

    except (json.JSONDecodeError, Exception):
        pass


if __name__ == "__main__":
    main()
