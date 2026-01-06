#!/usr/bin/env python3
"""
Stop hook - Send notification when Claude finishes.
Shows folder name and last 3 conversation messages.
"""

import json
import os
import subprocess
import sys


def get_last_messages(transcript_path: str, num_lines: int = 20) -> str:
    """Read last N lines from transcript and extract last 3 conversation messages."""
    if not transcript_path or not os.path.exists(transcript_path):
        return ""

    try:
        with open(transcript_path, "r", encoding="utf-8") as f:
            lines = f.readlines()

        recent_lines = lines[-num_lines:] if len(lines) >= num_lines else lines

        messages = []
        for line in recent_lines:
            try:
                entry = json.loads(line.strip())
                if not isinstance(entry, dict):
                    continue

                role = entry.get("role", "")
                content = entry.get("content", "")

                if role not in ("user", "assistant"):
                    continue

                # Handle string content
                if isinstance(content, str) and content.strip():
                    text = content.strip()[:60]
                    if len(content) > 60:
                        text += "..."
                    messages.append(f"{'👤' if role == 'user' else '🤖'} {text}")

                # Handle structured content (list)
                elif isinstance(content, list):
                    for item in content:
                        if isinstance(item, dict) and item.get("type") == "text":
                            text = item.get("text", "").strip()[:60]
                            if len(item.get("text", "")) > 60:
                                text += "..."
                            if text:
                                messages.append(
                                    f"{'👤' if role == 'user' else '🤖'} {text}"
                                )
                                break

            except json.JSONDecodeError:
                continue

        return "\n".join(messages[-3:]) if messages else ""
    except Exception:
        return ""


def main():
    try:
        raw_input = sys.stdin.read()

        if not raw_input.strip():
            subprocess.run(["say", "-r", "220", "對話已經完成"], check=False)
            subprocess.run(
                ["ntfy", "publish", "lizard", "Claude Code 對話結束"], check=False
            )
            return

        data = json.loads(raw_input)
        cwd = data.get("cwd", "")
        transcript_path = data.get("transcript_path", "")

        folder_name = os.path.basename(cwd) if cwd else ""
        last_messages = get_last_messages(transcript_path)

        # Build notification
        body_parts = []
        if folder_name:
            body_parts.append(f"📁 {folder_name}")
        if last_messages:
            body_parts.append(last_messages)

        full_body = "\n".join(body_parts) if body_parts else "對話已完成"

        subprocess.run(["say", "-r", "220", "對話已經完成"], check=False)
        subprocess.run(
            ["ntfy", "publish", "--title", "Claude Code 完成", "lizard", full_body],
            check=False,
        )

    except json.JSONDecodeError:
        subprocess.run(["say", "-r", "220", "對話已經完成"], check=False)
        subprocess.run(
            ["ntfy", "publish", "lizard", "Claude Code 對話結束"], check=False
        )
    except Exception:
        pass


if __name__ == "__main__":
    main()
