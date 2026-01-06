#!/usr/bin/env python3
"""
GitCheckpoint hook - Auto-checkpoint before risky operations.
Triggers: PreToolUse for Edit, MultiEdit, Write tools.

Features:
1. Auto-stash changes before risky operations
2. Create named checkpoints for easy rollback
3. Warn about uncommitted changes
"""

import json
import os
import subprocess
import sys
from datetime import datetime

# =============================================================================
# Configuration
# =============================================================================

LOG_DIR = os.path.expanduser("~/.claude/logs")
CHECKPOINT_PREFIX = "claude-checkpoint"

# File patterns that trigger checkpoint
RISKY_PATTERNS = [
    # Config files
    "package.json",
    "pyproject.toml",
    "tsconfig.json",
    ".env",
    "Dockerfile",
    "docker-compose",
    # Critical code
    "index.ts",
    "index.js",
    "main.py",
    "app.py",
    "server.ts",
    "server.js",
    # Database
    "schema.prisma",
    "migrations/",
    "*.sql",
]


def is_git_repo(cwd: str) -> bool:
    """Check if directory is a git repository."""
    try:
        result = subprocess.run(
            ["git", "rev-parse", "--is-inside-work-tree"],
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=5,
        )
        return result.returncode == 0
    except Exception:
        return False


def has_uncommitted_changes(cwd: str) -> bool:
    """Check if there are uncommitted changes."""
    try:
        result = subprocess.run(
            ["git", "status", "--porcelain"],
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=5,
        )
        return bool(result.stdout.strip())
    except Exception:
        return False


def create_stash_checkpoint(cwd: str, description: str) -> tuple[bool, str]:
    """Create a git stash checkpoint."""
    try:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        stash_name = f"{CHECKPOINT_PREFIX}_{timestamp}: {description[:50]}"

        result = subprocess.run(
            ["git", "stash", "push", "-m", stash_name, "--include-untracked"],
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=30,
        )

        if result.returncode == 0:
            return True, stash_name
        else:
            return False, result.stderr

    except subprocess.TimeoutExpired:
        return False, "Stash operation timed out"
    except Exception as e:
        return False, str(e)


def should_checkpoint(file_path: str) -> bool:
    """Check if file should trigger a checkpoint."""
    filename = os.path.basename(file_path)

    for pattern in RISKY_PATTERNS:
        if pattern.endswith("/"):
            # Directory pattern
            if pattern.rstrip("/") in file_path:
                return True
        elif "*" in pattern:
            # Wildcard pattern
            import fnmatch

            if fnmatch.fnmatch(filename, pattern):
                return True
        else:
            # Exact match
            if filename == pattern or pattern in file_path:
                return True

    return False


def log_checkpoint(cwd: str, file_path: str, stash_name: str, success: bool):
    """Log checkpoint creation."""
    os.makedirs(LOG_DIR, exist_ok=True)

    entry = {
        "timestamp": datetime.now().isoformat(),
        "cwd": cwd,
        "file": file_path,
        "stash_name": stash_name,
        "success": success,
    }

    with open(os.path.join(LOG_DIR, "checkpoints.jsonl"), "a") as f:
        f.write(json.dumps(entry, ensure_ascii=False) + "\n")


def main():
    try:
        raw_input = sys.stdin.read()
        if not raw_input.strip():
            sys.exit(0)

        data = json.loads(raw_input)
        tool_name = data.get("tool_name", "")
        tool_input = data.get("tool_input", {})
        cwd = data.get("cwd", "")

        # Only check for Write, Edit, MultiEdit
        if tool_name not in ["Write", "Edit", "MultiEdit"]:
            sys.exit(0)

        # Get file path(s)
        file_paths = []
        if tool_name == "MultiEdit":
            edits = tool_input.get("edits", [])
            file_paths = [e.get("file_path", "") for e in edits if e.get("file_path")]
        else:
            file_path = tool_input.get("file_path", "")
            if file_path:
                file_paths = [file_path]

        # Check if any file should trigger checkpoint
        should_create = False
        trigger_file = ""
        for fp in file_paths:
            if should_checkpoint(fp):
                should_create = True
                trigger_file = fp
                break

        if not should_create:
            sys.exit(0)

        # Check if in git repo with uncommitted changes
        if not is_git_repo(cwd):
            sys.exit(0)

        if not has_uncommitted_changes(cwd):
            sys.exit(0)

        # Create checkpoint
        description = f"Before editing {os.path.basename(trigger_file)}"
        success, stash_result = create_stash_checkpoint(cwd, description)

        # Log the checkpoint
        log_checkpoint(cwd, trigger_file, stash_result, success)

        if success:
            # Notify about checkpoint (non-blocking)
            response = {
                "continue": True,
                "systemMessage": f"📍 Checkpoint created: {stash_result}",
            }
            print(json.dumps(response))
        else:
            # Don't block on failure, just log
            pass

        sys.exit(0)

    except json.JSONDecodeError:
        sys.exit(0)
    except Exception:
        sys.exit(0)


if __name__ == "__main__":
    main()
