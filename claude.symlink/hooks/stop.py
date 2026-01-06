#!/usr/bin/env python3

import json
import os
import subprocess
import sys


def get_transcript_summary(transcript_path: str, num_lines: int = 10) -> str:
    """Read last N lines from transcript and extract conversation content."""
    if not transcript_path or not os.path.exists(transcript_path):
        return ""

    try:
        with open(transcript_path, "r", encoding="utf-8") as f:
            lines = f.readlines()

        # Get last N lines
        recent_lines = lines[-num_lines:] if len(lines) >= num_lines else lines

        summaries = []
        for line in recent_lines:
            try:
                entry = json.loads(line.strip())
                # Extract meaningful content based on message type
                if isinstance(entry, dict):
                    role = entry.get("role", "")
                    content = entry.get("content", "")

                    # Handle different content formats
                    if isinstance(content, str) and content:
                        text = content[:100]  # Truncate long content
                        if len(content) > 100:
                            text += "..."
                        summaries.append(f"[{role}] {text}")
                    elif isinstance(content, list):
                        # Handle structured content (tool use, etc.)
                        for item in content:
                            if isinstance(item, dict):
                                if item.get("type") == "text":
                                    text = item.get("text", "")[:80]
                                    if len(item.get("text", "")) > 80:
                                        text += "..."
                                    summaries.append(f"[{role}] {text}")
                                elif item.get("type") == "tool_use":
                                    tool_name = item.get("name", "unknown")
                                    summaries.append(f"[tool] {tool_name}")
                                elif item.get("type") == "tool_result":
                                    summaries.append("[tool_result]")
            except json.JSONDecodeError:
                continue

        return (
            "\n".join(summaries[-5:]) if summaries else ""
        )  # Return last 5 meaningful entries
    except Exception:
        return ""


def main():
    try:
        # Read JSON from stdin
        raw_input = sys.stdin.read()

        if not raw_input.strip():
            # Fallback if no input
            subprocess.run(["say", "-r", "220", "對話已經完成"], check=False)
            subprocess.run(
                ["ntfy", "publish", "lizard", "Claude Code 對話結束"], check=False
            )
            return

        # Parse JSON
        data = json.loads(raw_input)

        # Extract fields
        cwd = data.get("cwd", "")
        transcript_path = data.get("transcript_path", "")
        session_id = data.get("session_id", "")[:8]  # First 8 chars

        # Get basename of cwd
        folder_name = os.path.basename(cwd) if cwd else ""

        # Get transcript summary
        transcript_summary = get_transcript_summary(transcript_path)

        # Build notification body
        body_parts = ["對話已經完成"]
        if folder_name:
            body_parts.append(f"📁 {folder_name}")
        if session_id:
            body_parts.append(f"🔑 {session_id}")
        if transcript_summary:
            body_parts.append(f"---\n{transcript_summary}")

        full_body = "\n".join(body_parts)

        # Use macOS 'say' command
        subprocess.run(["say", "-r", "220", "對話已經完成"], check=False)

        # Send notification via ntfy with title
        subprocess.run(
            ["ntfy", "publish", "--title", "Claude Code 完成", "lizard", full_body],
            check=False,
        )

    except json.JSONDecodeError:
        # Fallback
        subprocess.run(["say", "-r", "220", "對話已經完成"], check=False)
        subprocess.run(
            ["ntfy", "publish", "lizard", "Claude Code 對話結束"], check=False
        )
    except Exception:
        pass


if __name__ == "__main__":
    main()
