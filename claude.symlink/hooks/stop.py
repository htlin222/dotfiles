#!/usr/bin/env python3
"""
Stop hook - Format files, backup transcript, and send notification when Claude finishes.

Features:
1. Format edited files with Biome/Prettier/Ruff (--write mode)
2. Backup transcript to ~/.claude/transcripts/
3. Log session summary to ~/.claude/logs/sessions.jsonl
4. Send git status via ntfy
"""

import json
import os
import shutil
import subprocess
import sys
import time
from datetime import datetime, timedelta

from ansi import C, Icons, git_status_emoji
from metrics import log_hook_event, log_hook_metrics

# Import TTS utility
from tts import notify_session_complete

# =============================================================================
# Configuration
# =============================================================================

LOG_DIR = os.path.expanduser("~/.claude/logs")
TRANSCRIPT_BACKUP_DIR = os.path.expanduser("~/.claude/transcripts")
EDIT_LOG_FILE = os.path.join(LOG_DIR, "edits.jsonl")
SESSION_LOG_FILE = os.path.join(LOG_DIR, "sessions.jsonl")
BASH_LOG_FILE = os.path.join(LOG_DIR, "bash_commands.jsonl")
SESSION_TIMEOUT_MINUTES = 60  # Only format files edited in last N minutes
MAX_TRANSCRIPT_BACKUPS = 50  # Keep last N transcript backups

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
    # R
    ".R": ["air", "format"],
}

# STATUS_ICONS imported from ansi.py as GIT_STATUS_ICONS


# =============================================================================
# Feature 1: File Formatting
# =============================================================================


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
            except (subprocess.TimeoutExpired, FileNotFoundError):
                pass

    return formatted_count


# =============================================================================
# Feature 2: Transcript Backup
# =============================================================================


def backup_transcript(
    transcript_path: str, project_name: str, session_id: str
) -> str | None:
    """Backup transcript file. Returns backup path or None."""
    if not transcript_path or not os.path.exists(transcript_path):
        return None

    os.makedirs(TRANSCRIPT_BACKUP_DIR, exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    safe_session_id = session_id[:8] if session_id else "unknown"
    backup_name = f"{project_name}_{timestamp}_{safe_session_id}.jsonl"
    backup_path = os.path.join(TRANSCRIPT_BACKUP_DIR, backup_name)

    try:
        shutil.copy2(transcript_path, backup_path)
        cleanup_old_backups()
        return backup_path
    except Exception:
        return None


def cleanup_old_backups():
    """Remove old transcript backups, keeping only the most recent ones."""
    try:
        backups = sorted(
            [f for f in os.listdir(TRANSCRIPT_BACKUP_DIR) if f.endswith(".jsonl")],
            key=lambda x: os.path.getmtime(os.path.join(TRANSCRIPT_BACKUP_DIR, x)),
            reverse=True,
        )
        for old_backup in backups[MAX_TRANSCRIPT_BACKUPS:]:
            os.remove(os.path.join(TRANSCRIPT_BACKUP_DIR, old_backup))
    except Exception:
        pass


# =============================================================================
# Feature 3: Session Summary
# =============================================================================


def get_session_stats() -> dict:
    """Get session statistics from logs."""
    stats = {
        "files_edited": 0,
        "bash_commands": 0,
        "unique_files": set(),
    }

    cutoff = datetime.now() - timedelta(minutes=SESSION_TIMEOUT_MINUTES)

    # Count edited files
    if os.path.exists(EDIT_LOG_FILE):
        try:
            with open(EDIT_LOG_FILE, encoding="utf-8") as f:
                for line in f:
                    try:
                        entry = json.loads(line.strip())
                        timestamp = datetime.fromisoformat(entry.get("timestamp", ""))
                        if timestamp >= cutoff:
                            stats["files_edited"] += 1
                            stats["unique_files"].add(entry.get("file", ""))
                    except (json.JSONDecodeError, ValueError):
                        continue
        except Exception:
            pass

    # Count bash commands
    if os.path.exists(BASH_LOG_FILE):
        try:
            with open(BASH_LOG_FILE, encoding="utf-8") as f:
                for line in f:
                    try:
                        entry = json.loads(line.strip())
                        timestamp = datetime.fromisoformat(entry.get("timestamp", ""))
                        if timestamp >= cutoff:
                            stats["bash_commands"] += 1
                    except (json.JSONDecodeError, ValueError):
                        continue
        except Exception:
            pass

    stats["unique_files"] = len(stats["unique_files"])
    return stats


def log_session_summary(
    session_id: str,
    cwd: str,
    project_name: str,
    stats: dict,
    transcript_backup: str | None,
):
    """Log session summary to sessions.jsonl."""
    os.makedirs(LOG_DIR, exist_ok=True)

    entry = {
        "timestamp": datetime.now().isoformat(),
        "session_id": session_id,
        "project": project_name,
        "cwd": cwd,
        "stats": {
            "files_edited": stats["files_edited"],
            "unique_files": stats["unique_files"],
            "bash_commands": stats["bash_commands"],
        },
        "transcript_backup": transcript_backup,
    }

    try:
        with open(SESSION_LOG_FILE, "a", encoding="utf-8") as f:
            f.write(json.dumps(entry, ensure_ascii=False) + "\n")
    except Exception:
        pass


# =============================================================================
# Feature 4: Git Status & Notification
# =============================================================================


def format_status_line(line: str) -> str:
    """Convert git status line to emoji format for ntfy."""
    if len(line) < 3:
        return line
    code = line[:2]
    path = line[3:].rstrip("/")
    filename = os.path.basename(path)
    parent = os.path.basename(os.path.dirname(path))
    display_name = f"{parent}/{filename}" if parent else filename
    emoji = git_status_emoji(code)
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
            capture_output=True,
        )

    except Exception:
        subprocess.run(
            ["ntfy", "publish", "--title", title, "lizard", "對話已完成"],
            check=False,
            capture_output=True,
        )


# =============================================================================
# Main
# =============================================================================


def main():
    start_time = time.time()
    try:
        raw_input = sys.stdin.read()

        if not raw_input.strip():
            subprocess.run(
                ["ntfy", "publish", "lizard", "Claude Code 對話結束"],
                check=False,
                capture_output=True,
            )
            print(json.dumps({"continue": True}))
            return

        data = json.loads(raw_input)
        cwd = data.get("cwd", "")
        session_id = data.get("session_id", "unknown")
        transcript_path = data.get("transcript_path", "")
        folder_name = os.path.basename(cwd) if cwd else ""

        # Feature 1: Format edited files
        edited_files = get_recent_edited_files()
        formatted_count = 0
        if edited_files:
            formatted_count = format_edited_files(edited_files)

        # Feature 2: Backup transcript
        transcript_backup = backup_transcript(transcript_path, folder_name, session_id)

        # Feature 3: Log session summary
        stats = get_session_stats()
        log_session_summary(session_id, cwd, folder_name, stats, transcript_backup)

        # Feature 4: Git status & notification
        get_git_status_and_notify(cwd, folder_name)

        # Feature 5: TTS notification with rich summary
        notify_session_complete(
            project_name=folder_name,
            files_formatted=formatted_count,
            files_edited=stats["unique_files"],
            transcript_backed_up=bool(transcript_backup),
        )

        # Log metrics
        execution_time_ms = (time.time() - start_time) * 1000
        log_hook_metrics(
            hook_name="stop",
            event_type="Stop",
            execution_time_ms=execution_time_ms,
            success=True,
            extra={
                "session_id": session_id,
                "files_formatted": formatted_count,
                "files_edited": stats["unique_files"],
                "bash_commands": stats["bash_commands"],
                "transcript_backed_up": bool(transcript_backup),
            },
        )

        log_hook_event(
            event_type="Stop",
            hook_name="stop",
            session_id=session_id,
            cwd=cwd,
            metadata={
                "project": folder_name,
                "stats": stats,
            },
        )

        # Print summary to stderr (visible in transcript mode)
        if formatted_count > 0 or transcript_backup:
            summary_parts = []
            if formatted_count > 0:
                summary_parts.append(
                    f"{C.BRIGHT_GREEN}{Icons.CHECK}{C.RESET} "
                    f"{C.BRIGHT_WHITE}{formatted_count}{C.RESET} files formatted"
                )
            if transcript_backup:
                summary_parts.append(
                    f"{C.BRIGHT_CYAN}{Icons.SAVE}{C.RESET} Transcript backed up"
                )
            print(f" {C.DIM}│{C.RESET} ".join(summary_parts), file=sys.stderr)

        # Output valid JSON response for Claude Code
        print(json.dumps({"continue": True}))

    except json.JSONDecodeError:
        subprocess.run(
            ["ntfy", "publish", "lizard", "Claude Code 對話結束"],
            check=False,
            capture_output=True,
        )
        print(json.dumps({"continue": True}))
    except Exception:
        print(json.dumps({"continue": True}))


if __name__ == "__main__":
    main()
