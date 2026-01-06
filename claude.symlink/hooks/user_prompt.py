#!/usr/bin/env python3
"""
UserPromptSubmit hook - Validate and process user input before sending to Claude.
Triggers: when user submits a prompt (before Claude sees it).

Features:
1. Safety check for dangerous commands
2. Log prompts for reference
3. Skills Auto-Activation - suggest relevant skills based on keywords
"""

import json
import os
import re
import sys
from datetime import datetime

# =============================================================================
# Configuration
# =============================================================================

LOG_DIR = os.path.expanduser("~/.claude/logs")

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

# Skills auto-activation rules
# Format: (keywords, intent_patterns, skill_name, suggestion_message)
SKILL_RULES = [
    # Frontend Development
    (
        [
            "component",
            "ui",
            "button",
            "form",
            "modal",
            "dialog",
            "css",
            "style",
            "tailwind",
            "react",
            "vue",
        ],
        [r"create.*(?:component|ui|button|form)", r"build.*(?:interface|page|layout)"],
        "frontend-design",
        "💡 建議使用 /frontend-design 來建立 UI 元件",
    ),
    # Code Review
    (
        ["review", "check", "審查", "檢查代碼"],
        [r"review.*(?:code|pr|pull)", r"check.*(?:quality|code)"],
        "code-review",
        "💡 建議使用 /code-review 進行程式碼審查",
    ),
    # Feature Development
    (
        ["feature", "implement", "功能", "實作"],
        [r"(?:add|create|implement|build).*feature", r"新增.*功能"],
        "feature-dev",
        "💡 建議使用 /feature-dev 進行功能開發",
    ),
    # Git Operations
    (
        ["commit", "push", "merge", "branch", "rebase", "pr", "pull request"],
        [r"(?:create|make).*(?:commit|pr|branch)", r"git.*(?:push|merge)"],
        "git",
        "💡 建議使用 /git 進行版本控制操作",
    ),
    # Testing
    (
        ["test", "testing", "spec", "e2e", "unit test", "測試"],
        [r"(?:write|create|add).*test", r"run.*test"],
        "test",
        "💡 建議使用 /test 進行測試相關操作",
    ),
    # Documentation
    (
        ["document", "readme", "doc", "文件", "說明"],
        [r"(?:write|create|update).*(?:doc|readme|documentation)"],
        "document",
        "💡 建議使用 /document 生成文件",
    ),
    # Analysis
    (
        ["analyze", "分析", "investigate", "debug", "troubleshoot"],
        [r"(?:analyze|investigate|debug|find).*(?:issue|bug|problem|error)"],
        "analyze",
        "💡 建議使用 /analyze 進行深度分析",
    ),
    # Build & Deploy
    (
        ["build", "deploy", "ci", "cd", "pipeline", "docker"],
        [r"(?:set up|create|configure).*(?:build|deploy|ci|cd|pipeline)"],
        "build",
        "💡 建議使用 /build 進行建置相關操作",
    ),
    # Cleanup & Refactor
    (
        ["cleanup", "refactor", "clean", "整理", "重構"],
        [r"(?:cleanup|refactor|clean up|reorganize)"],
        "cleanup",
        "💡 建議使用 /cleanup 進行程式碼清理",
    ),
    # Design & Architecture
    (
        ["design", "architecture", "設計", "架構", "schema", "database"],
        [r"(?:design|architect|plan).*(?:system|api|database|schema)"],
        "design",
        "💡 建議使用 /design 進行系統設計",
    ),
]


# =============================================================================
# Feature 1: Dangerous Pattern Check
# =============================================================================


def check_dangerous_patterns(prompt: str) -> str | None:
    """Check for dangerous command patterns. Returns warning message or None."""
    prompt_lower = prompt.lower()
    for pattern, warning in DANGEROUS_PATTERNS:
        if re.search(pattern, prompt_lower):
            return warning
    return None


# =============================================================================
# Feature 2: Prompt Logging
# =============================================================================


def log_prompt(cwd: str, prompt: str):
    """Log user prompt to file for reference."""
    os.makedirs(LOG_DIR, exist_ok=True)

    log_file = os.path.join(LOG_DIR, "prompts.jsonl")
    entry = {
        "timestamp": datetime.now().isoformat(),
        "cwd": cwd,
        "prompt": prompt[:500],  # Truncate long prompts
    }

    with open(log_file, "a", encoding="utf-8") as f:
        f.write(json.dumps(entry, ensure_ascii=False) + "\n")


# =============================================================================
# Feature 3: Skills Auto-Activation
# =============================================================================


def suggest_skill(prompt: str) -> str | None:
    """Suggest a skill based on prompt keywords and patterns."""
    prompt_lower = prompt.lower()

    for keywords, patterns, skill_name, suggestion in SKILL_RULES:
        # Check if prompt already mentions the skill (avoid redundant suggestions)
        if f"/{skill_name}" in prompt_lower:
            continue

        # Check keywords
        keyword_match = any(kw in prompt_lower for kw in keywords)

        # Check intent patterns
        pattern_match = any(re.search(p, prompt_lower) for p in patterns)

        if keyword_match or pattern_match:
            return suggestion

    return None


# =============================================================================
# Main
# =============================================================================


def main():
    try:
        raw_input = sys.stdin.read()
        if not raw_input.strip():
            return

        data = json.loads(raw_input)
        prompt = data.get("prompt", "")
        cwd = data.get("cwd", "")

        messages = []

        # Log the prompt
        if prompt:
            log_prompt(cwd, prompt)

        # Check for dangerous patterns
        warning = check_dangerous_patterns(prompt)
        if warning:
            messages.append(f"⚠️ {warning} - 請確認這是你想要的操作")

        # Suggest skill if applicable
        skill_suggestion = suggest_skill(prompt)
        if skill_suggestion:
            messages.append(skill_suggestion)

        # Output response if there are messages
        if messages:
            response = {
                "continue": True,
                "systemMessage": "\n".join(messages),
            }
            print(json.dumps(response))

    except (json.JSONDecodeError, Exception):
        pass


if __name__ == "__main__":
    main()
