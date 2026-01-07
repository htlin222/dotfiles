#!/usr/bin/env python3
"""
Shared TTS (Text-to-Speech) utility for Claude Code hooks.

Features:
1. Non-blocking TTS using subprocess.Popen
2. Mute mode via CLAUDE_MUTE environment variable
3. Fallback handling for systems without 'say' command
4. Rich notification messages based on hook data
"""

import os
import shutil
import subprocess

# Configuration
DEFAULT_VOICE = "Samantha"
DEFAULT_RATE = 200  # Words per minute


def is_muted() -> bool:
    """Check if TTS is muted via environment variable."""
    return os.environ.get("CLAUDE_MUTE", "").lower() in ("1", "true", "yes")


def say(message: str, voice: str = DEFAULT_VOICE, rate: int = DEFAULT_RATE) -> bool:
    """
    Non-blocking TTS notification.

    Args:
        message: Text to speak
        voice: macOS voice name (default: Samantha)
        rate: Speech rate in words per minute

    Returns:
        True if TTS was initiated, False if skipped/failed
    """
    if is_muted():
        return False

    if not shutil.which("say"):
        return False  # say command not available (Linux)

    try:
        subprocess.Popen(
            ["say", "-v", voice, "-r", str(rate), message],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        return True
    except Exception:
        return False


# =============================================================================
# Rich notification builders for each hook type
# =============================================================================


def notify_file_saved(file_path: str, tool_name: str) -> bool:
    """Notify when a file is saved/edited."""
    filename = os.path.basename(file_path) if file_path else "file"
    # Keep it short for frequent operations
    return say(f"{filename} saved")


def notify_bash_complete(command: str, exit_code: int | None, cwd: str) -> bool:
    """Notify when a bash command completes (only for long/important commands)."""
    # Skip notification for common quick commands
    quick_commands = ("ls", "cd", "pwd", "echo", "cat", "head", "tail", "grep")
    cmd_name = command.split()[0] if command else ""

    if cmd_name in quick_commands:
        return False

    # Only notify on errors or specific commands
    if exit_code is not None and exit_code != 0:
        return say(f"Command failed with exit code {exit_code}")

    # Notify for specific important commands
    important_prefixes = ("git push", "git commit", "npm", "pnpm", "yarn", "make", "docker")
    if any(command.startswith(p) for p in important_prefixes):
        return say("Command completed")

    return False


def notify_session_complete(
    project_name: str,
    files_formatted: int = 0,
    files_edited: int = 0,
    transcript_backed_up: bool = False,
) -> bool:
    """Notify when a session completes with summary."""
    parts = []

    if project_name:
        parts.append(f"{project_name}")

    if files_edited > 0:
        parts.append(f"{files_edited} files changed")

    if files_formatted > 0:
        parts.append(f"{files_formatted} formatted")

    if transcript_backed_up:
        parts.append("transcript saved")

    if parts:
        message = ", ".join(parts) + ". Session complete."
    else:
        message = "Session complete"

    return say(message)


def notify_subagent_complete(project_name: str = "") -> bool:
    """Notify when a subagent completes."""
    if project_name:
        return say(f"Subagent finished in {project_name}")
    return say("Subagent complete")


def notify_compact(project_name: str = "") -> bool:
    """Notify before context compaction."""
    if project_name:
        return say(f"Compacting {project_name} context")
    return say("Compacting context")


def notify_notification(title: str = "", body: str = "") -> bool:
    """Notify for Claude notifications."""
    if title:
        return say(f"Notification: {title}")
    return say("Notification from Claude")
