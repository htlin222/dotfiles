#!/usr/bin/env python3
"""
UserPromptSubmit hook - Validate and process user input before sending to Claude.
Triggers: when user submits a prompt (before Claude sees it).

Features:
- Safety check for dangerous commands
- Log prompts for reference
- Can inject additional context
"""

import json
import os
import re
import sys
from datetime import datetime


# Dangerous patterns to warn about (not block, just warn)
DANGEROUS_PATTERNS = [
    (r"rm\s+-rf\s+[/~]", "危險：嘗試刪除根目錄或家目錄"),
    (r"rm\s+-rf\s+\*", "危險：嘗試刪除所有檔案"),
    (r":(){ :\|:& };:", "危險：Fork bomb 偵測"),
    (r"mkfs\.", "危險：格式化磁碟指令"),
    (r"dd\s+if=.+of=/dev/", "危險：覆寫磁碟指令"),
    (r">\s*/dev/sda", "危險：覆寫磁碟"),
    (r"chmod\s+-R\s+777\s+/", "危險：開放所有權限"),
]


def check_dangerous_patterns(prompt: str) -> str | None:
    """Check for dangerous command patterns. Returns warning message or None."""
    prompt_lower = prompt.lower()
    for pattern, warning in DANGEROUS_PATTERNS:
        if re.search(pattern, prompt_lower):
            return warning
    return None


def log_prompt(cwd: str, prompt: str):
    """Log user prompt to file for reference."""
    log_dir = os.path.expanduser("~/.claude/logs")
    os.makedirs(log_dir, exist_ok=True)

    log_file = os.path.join(log_dir, "prompts.jsonl")
    entry = {
        "timestamp": datetime.now().isoformat(),
        "cwd": cwd,
        "prompt": prompt[:500],  # Truncate long prompts
    }

    with open(log_file, "a", encoding="utf-8") as f:
        f.write(json.dumps(entry, ensure_ascii=False) + "\n")


def main():
    try:
        raw_input = sys.stdin.read()
        if not raw_input.strip():
            return

        data = json.loads(raw_input)
        prompt = data.get("prompt", "")
        cwd = data.get("cwd", "")

        # Log the prompt
        if prompt:
            log_prompt(cwd, prompt)

        # Check for dangerous patterns
        warning = check_dangerous_patterns(prompt)

        if warning:
            # Warn but don't block - output JSON response
            response = {
                "continue": True,  # Still allow, just warn
                "systemMessage": f"⚠️ {warning} - 請確認這是你想要的操作",
            }
            print(json.dumps(response))
        # If no warning, just let it pass (no output needed)

    except (json.JSONDecodeError, Exception):
        pass


if __name__ == "__main__":
    main()
