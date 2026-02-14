#!/usr/bin/env python3
"""Extract human-readable content from Claude Code session JSONL files.

Parses Claude Code conversation logs and extracts only:
  - User prompts (human's questions/instructions)
  - Assistant prose responses (explanations, summaries, answers)

Skips:
  - tool_use blocks (bash commands, file reads/writes, search queries)
  - tool_result blocks (command output, file contents, API responses)
  - thinking blocks (internal reasoning)
  - system-reminder tags embedded in user messages
  - progress/hook events
  - file-history-snapshot entries

Usage:
    # Auto-detect latest session for current project
    python extract_conversation.py

    # Specify a session JSONL file
    python extract_conversation.py /path/to/session.jsonl

    # Output as JSON instead of markdown
    python extract_conversation.py --format json

    # Include timestamps
    python extract_conversation.py --timestamps
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Literal


# ---------------------------------------------------------------------------
# Data model
# ---------------------------------------------------------------------------

Role = Literal["user", "assistant"]


@dataclass
class Message:
    role: Role
    text: str
    timestamp: str = ""
    uuid: str = ""
    parent_uuid: str = ""


# ---------------------------------------------------------------------------
# Parsing helpers
# ---------------------------------------------------------------------------

_SYSTEM_REMINDER_RE = re.compile(r"<system-reminder>.*?</system-reminder>", re.DOTALL)


def strip_system_reminders(text: str) -> str:
    """Remove all <system-reminder>...</system-reminder> blocks."""
    return _SYSTEM_REMINDER_RE.sub("", text).strip()


def extract_user_text(content) -> str | None:
    """Extract human-typed text from a user message's content field.

    User messages come in two shapes:
      1. content is a plain string  -> the user's prompt
      2. content is a list of blocks -> may contain tool_result (skip)
         or text blocks (rare, but possible)
    """
    if isinstance(content, str):
        cleaned = strip_system_reminders(content)
        return cleaned if cleaned else None

    if isinstance(content, list):
        parts: list[str] = []
        for block in content:
            if not isinstance(block, dict):
                continue
            btype = block.get("type", "")
            if btype == "tool_result":
                continue  # skip tool outputs
            if btype == "text":
                text = block.get("text", "")
                cleaned = strip_system_reminders(text)
                if cleaned:
                    parts.append(cleaned)
        return "\n".join(parts) if parts else None

    return None


def extract_assistant_text(content) -> str | None:
    """Extract prose text from an assistant message's content field.

    Assistant content is always a list of blocks. We keep only 'text' blocks,
    skipping 'tool_use', 'thinking', 'server_tool_use', etc.
    """
    if not isinstance(content, list):
        return None

    parts: list[str] = []
    for block in content:
        if not isinstance(block, dict):
            continue
        if block.get("type") == "text":
            text = block.get("text", "").strip()
            if text:
                parts.append(text)
    return "\n\n".join(parts) if parts else None


# ---------------------------------------------------------------------------
# JSONL reader
# ---------------------------------------------------------------------------


def parse_session(path: Path) -> list[Message]:
    """Read a session JSONL file and return human-readable messages."""
    messages: list[Message] = []

    with open(path, encoding="utf-8") as fh:
        for lineno, line in enumerate(fh, 1):
            line = line.strip()
            if not line:
                continue
            try:
                record = json.loads(line)
            except json.JSONDecodeError:
                print(
                    f"warning: skipping malformed JSON at line {lineno}",
                    file=sys.stderr,
                )
                continue

            rtype = record.get("type", "")
            if rtype not in ("user", "assistant"):
                continue  # skip progress, file-history-snapshot, etc.

            msg = record.get("message")
            if not msg or not isinstance(msg, dict):
                continue

            role = msg.get("role", rtype)
            content = msg.get("content")
            if content is None:
                continue

            timestamp = record.get("timestamp", "")
            uuid = record.get("uuid", "")
            parent_uuid = record.get("parentUuid", "")

            if role == "user":
                text = extract_user_text(content)
            elif role == "assistant":
                text = extract_assistant_text(content)
            else:
                continue

            if text:
                messages.append(
                    Message(
                        role=role,
                        text=text,
                        timestamp=timestamp,
                        uuid=uuid,
                        parent_uuid=parent_uuid,
                    )
                )

    return messages


# ---------------------------------------------------------------------------
# Session discovery
# ---------------------------------------------------------------------------


def find_project_sessions(project_dir: Path | None = None) -> list[Path]:
    """Find all session JSONL files for a project directory.

    Claude Code stores sessions in:
        ~/.claude/projects/-{project-path-dashes}/{session-id}.jsonl
    """
    claude_dir = Path.home() / ".claude" / "projects"
    if not claude_dir.is_dir():
        return []

    if project_dir is None:
        project_dir = Path.cwd()

    # Claude Code encodes the project path by replacing / and . with -
    encoded = str(project_dir).replace("/", "-").replace(".", "-")
    session_dir = claude_dir / encoded

    if not session_dir.is_dir():
        # Try fuzzy match (partial path)
        candidates = []
        for d in claude_dir.iterdir():
            if d.is_dir() and encoded in d.name:
                candidates.append(d)
        if not candidates:
            return []
        session_dir = max(candidates, key=lambda d: d.stat().st_mtime)

    jsonl_files = sorted(session_dir.glob("*.jsonl"), key=lambda p: p.stat().st_mtime)
    return jsonl_files


def find_latest_session(project_dir: Path | None = None) -> Path | None:
    """Return the most recently modified session JSONL for a project."""
    sessions = find_project_sessions(project_dir)
    return sessions[-1] if sessions else None


# ---------------------------------------------------------------------------
# Output formatters
# ---------------------------------------------------------------------------


def format_markdown(messages: list[Message], *, timestamps: bool = False) -> str:
    """Render messages as a readable Markdown transcript."""
    lines: list[str] = []
    for msg in messages:
        prefix = "**User**" if msg.role == "user" else "**Assistant**"
        if timestamps and msg.timestamp:
            ts = msg.timestamp[:19].replace("T", " ")  # trim to seconds
            prefix = f"{prefix} ({ts})"
        lines.append(f"### {prefix}\n")
        lines.append(msg.text)
        lines.append("")  # blank separator
    return "\n".join(lines)


def format_json(messages: list[Message], *, timestamps: bool = False) -> str:
    """Render messages as a JSON array."""
    out = []
    for msg in messages:
        entry: dict = {"role": msg.role, "text": msg.text}
        if timestamps and msg.timestamp:
            entry["timestamp"] = msg.timestamp
        out.append(entry)
    return json.dumps(out, indent=2, ensure_ascii=False)


def format_plain(messages: list[Message], *, timestamps: bool = False) -> str:
    """Render messages as plain text with role labels."""
    lines: list[str] = []
    for msg in messages:
        label = "USER" if msg.role == "user" else "ASSISTANT"
        if timestamps and msg.timestamp:
            ts = msg.timestamp[:19].replace("T", " ")
            label = f"{label} [{ts}]"
        lines.append(f"=== {label} ===")
        lines.append(msg.text)
        lines.append("")
    return "\n".join(lines)


FORMATTERS = {
    "markdown": format_markdown,
    "md": format_markdown,
    "json": format_json,
    "plain": format_plain,
    "text": format_plain,
}


# ---------------------------------------------------------------------------
# Statistics
# ---------------------------------------------------------------------------


def print_stats(messages: list[Message], file=sys.stderr) -> None:
    """Print summary statistics about the extracted conversation."""
    user_msgs = [m for m in messages if m.role == "user"]
    asst_msgs = [m for m in messages if m.role == "assistant"]
    total_chars = sum(len(m.text) for m in messages)
    print(
        f"Extracted: {len(messages)} messages "
        f"({len(user_msgs)} user, {len(asst_msgs)} assistant), "
        f"{total_chars:,} chars total",
        file=file,
    )


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        description="Extract human-readable content from Claude Code sessions.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    p.add_argument(
        "session_file",
        nargs="?",
        type=Path,
        help="Path to session JSONL file (auto-detects latest if omitted)",
    )
    p.add_argument(
        "--project-dir",
        type=Path,
        default=None,
        help="Project directory for auto-detection (defaults to cwd)",
    )
    p.add_argument(
        "--format",
        "-f",
        choices=list(FORMATTERS),
        default="markdown",
        help="Output format (default: markdown)",
    )
    p.add_argument(
        "--timestamps",
        "-t",
        action="store_true",
        help="Include timestamps in output",
    )
    p.add_argument(
        "--output",
        "-o",
        type=Path,
        default=None,
        help="Write output to file instead of stdout",
    )
    p.add_argument(
        "--stats",
        action="store_true",
        help="Print extraction statistics to stderr",
    )
    p.add_argument(
        "--list-sessions",
        action="store_true",
        help="List available sessions and exit",
    )
    return p


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    # List sessions mode
    if args.list_sessions:
        sessions = find_project_sessions(args.project_dir)
        if not sessions:
            print("No sessions found.", file=sys.stderr)
            return 1
        for s in sessions:
            mtime = s.stat().st_mtime
            from datetime import datetime, timezone

            ts = datetime.fromtimestamp(mtime, tz=timezone.utc).strftime(
                "%Y-%m-%d %H:%M:%S"
            )
            size_kb = s.stat().st_size / 1024
            print(f"  {ts}  {size_kb:8.1f}KB  {s.name}")
        return 0

    # Resolve session file
    session_path = args.session_file
    if session_path is None:
        session_path = find_latest_session(args.project_dir)
        if session_path is None:
            print(
                "error: no session file found. "
                "Provide a path or run from a project directory.",
                file=sys.stderr,
            )
            return 1
        print(f"Using session: {session_path}", file=sys.stderr)

    if not session_path.is_file():
        print(f"error: file not found: {session_path}", file=sys.stderr)
        return 1

    # Parse and format
    messages = parse_session(session_path)
    if not messages:
        print("No human-readable messages found.", file=sys.stderr)
        return 1

    if args.stats:
        print_stats(messages)

    formatter = FORMATTERS[args.format]
    output = formatter(messages, timestamps=args.timestamps)

    if args.output:
        args.output.write_text(output, encoding="utf-8")
        print(f"Written to {args.output}", file=sys.stderr)
    else:
        print(output)

    return 0


if __name__ == "__main__":
    sys.exit(main())
