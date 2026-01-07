#!/usr/bin/env python3
"""
UserPromptSubmit hook - Validate and process user input before sending to Claude.
Triggers: when user submits a prompt (before Claude sees it).

Features:
1. Safety check for dangerous commands
2. Log prompts for reference
3. Skills Auto-Activation - suggest relevant skills based on keywords
4. Project-aware suggestions - detect project type and suggest relevant skills
5. Smart context loading - suggest /prime or /load for large projects
6. Git status reminder - warn about uncommitted changes
7. Similar prompt detection - suggest previous solutions
8. Token estimation warning - detect potentially expensive requests
9. Time reminder - late night / long session warnings
"""

import hashlib
import json
import os
import re
import subprocess
import sys
import time
from datetime import datetime

# Import metrics and pattern detection
from metrics import estimate_tokens, log_hook_event, log_hook_metrics
from patterns import detect_patterns, format_suggestions

# =============================================================================
# Configuration
# =============================================================================

LOG_DIR = os.path.expanduser("~/.claude/logs")
STATE_FILE = os.path.join(LOG_DIR, "hook_state.json")

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

# Project type detection
PROJECT_TYPES = {
    "node": {
        "files": ["package.json"],
        "skills": ["build", "test"],
        "message": "📦 Node.js 專案",
    },
    "python": {
        "files": ["pyproject.toml", "setup.py", "requirements.txt"],
        "skills": ["test", "analyze"],
        "message": "🐍 Python 專案",
    },
    "rust": {
        "files": ["Cargo.toml"],
        "skills": ["build", "test"],
        "message": "🦀 Rust 專案",
    },
    "go": {
        "files": ["go.mod"],
        "skills": ["build", "test"],
        "message": "🐹 Go 專案",
    },
    "ruby": {
        "files": ["Gemfile"],
        "skills": ["test"],
        "message": "💎 Ruby 專案",
    },
    "java": {
        "files": ["pom.xml", "build.gradle"],
        "skills": ["build", "test"],
        "message": "☕ Java 專案",
    },
}

# Token estimation patterns (potentially expensive)
TOKEN_HEAVY_PATTERNS = [
    (
        r"整個專案|entire project|whole codebase|all files",
        "⚠️ 整個專案操作可能消耗大量 tokens",
    ),
    (r"所有檔案|every file|each file", "⚠️ 處理所有檔案可能消耗大量 tokens"),
    (r"重構整個|refactor all|refactor entire", "⚠️ 大規模重構可能消耗大量 tokens"),
    (
        r"完整分析|full analysis|comprehensive review",
        "⚠️ 完整分析可能消耗大量 tokens，建議分階段進行",
    ),
    (r"從頭開始|from scratch|start over", "⚠️ 從頭開始可能消耗大量 tokens"),
]


# =============================================================================
# State Management
# =============================================================================


def load_state() -> dict:
    """Load persistent state from file."""
    try:
        if os.path.exists(STATE_FILE):
            with open(STATE_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
    except Exception:
        pass
    return {
        "session_start": None,
        "prompt_count": 0,
        "prompt_hashes": [],
        "last_git_check": None,
        "last_context_suggestion": None,
    }


def save_state(state: dict):
    """Save persistent state to file."""
    try:
        os.makedirs(LOG_DIR, exist_ok=True)
        with open(STATE_FILE, "w", encoding="utf-8") as f:
            json.dump(state, f, ensure_ascii=False, indent=2)
    except Exception:
        pass


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
# Feature 4: Project-aware Suggestions
# =============================================================================


def detect_project_type(cwd: str) -> dict | None:
    """Detect project type based on config files."""
    if not cwd:
        return None

    for project_type, config in PROJECT_TYPES.items():
        for file in config["files"]:
            if os.path.exists(os.path.join(cwd, file)):
                return {"type": project_type, **config}
    return None


# =============================================================================
# Feature 5: Smart Context Loading
# =============================================================================


def check_large_project(cwd: str, state: dict) -> str | None:
    """Check if project is large and suggest context loading."""
    if not cwd:
        return None

    # Don't suggest too frequently (once per 10 prompts)
    if state.get("last_context_suggestion"):
        prompts_since = state.get("prompt_count", 0) - state.get(
            "last_context_suggestion", 0
        )
        if prompts_since < 10:
            return None

    try:
        # Count files (rough estimate)
        file_count = 0
        for root, dirs, files in os.walk(cwd):
            # Skip common non-source directories
            dirs[:] = [
                d
                for d in dirs
                if d
                not in [
                    ".git",
                    "node_modules",
                    "__pycache__",
                    ".venv",
                    "venv",
                    "dist",
                    "build",
                    ".next",
                ]
            ]
            file_count += len(files)
            if file_count > 100:
                break

        if file_count > 100:
            state["last_context_suggestion"] = state.get("prompt_count", 0)
            return "📂 大型專案偵測（100+ 檔案），建議先執行 /prime 載入 context"

    except Exception:
        pass

    return None


# =============================================================================
# Feature 6: Git Status Reminder
# =============================================================================


def check_git_status(cwd: str, state: dict) -> str | None:
    """Check git status and warn about uncommitted changes."""
    if not cwd:
        return None

    # Check at most once per 5 prompts
    if state.get("last_git_check"):
        prompts_since = state.get("prompt_count", 0) - state.get("last_git_check", 0)
        if prompts_since < 5:
            return None

    try:
        # Check if in git repo
        result = subprocess.run(
            ["git", "rev-parse", "--is-inside-work-tree"],
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=5,
        )
        if result.returncode != 0:
            return None

        # Get status
        result = subprocess.run(
            ["git", "status", "--porcelain"],
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=5,
        )

        state["last_git_check"] = state.get("prompt_count", 0)

        if result.stdout.strip():
            lines = result.stdout.strip().split("\n")
            change_count = len(lines)
            if change_count > 10:
                return f"📝 Git: {change_count} 個未提交變更，建議適時 commit"

    except Exception:
        pass

    return None


# =============================================================================
# Feature 7: Similar Prompt Detection
# =============================================================================


def check_similar_prompt(prompt: str, state: dict) -> str | None:
    """Check for similar previous prompts."""
    # Create a simple hash of the prompt (normalized)
    normalized = re.sub(r"\s+", " ", prompt.lower().strip())
    prompt_hash = hashlib.md5(normalized.encode()).hexdigest()[:8]

    prompt_hashes = state.get("prompt_hashes", [])

    # Check for exact or similar match
    if prompt_hash in prompt_hashes:
        return "🔄 偵測到相似問題，可參考之前的對話紀錄"

    # Keep last 50 prompt hashes
    prompt_hashes.append(prompt_hash)
    state["prompt_hashes"] = prompt_hashes[-50:]

    return None


# =============================================================================
# Feature 8: Token Estimation Warning
# =============================================================================


def check_token_heavy(prompt: str) -> str | None:
    """Check for potentially token-heavy requests."""
    prompt_lower = prompt.lower()
    for pattern, warning in TOKEN_HEAVY_PATTERNS:
        if re.search(pattern, prompt_lower):
            return warning
    return None


# =============================================================================
# Feature 9: Time Reminder
# =============================================================================


def check_time_reminder(state: dict) -> str | None:
    """Check for late night or long session."""
    now = datetime.now()
    messages = []

    # Late night check (23:00 - 05:00)
    if now.hour >= 23 or now.hour < 5:
        messages.append("🌙 深夜了，注意休息")

    # Long session check
    session_start = state.get("session_start")
    if session_start:
        try:
            start_time = datetime.fromisoformat(session_start)
            duration = (now - start_time).total_seconds() / 3600  # hours
            if duration > 2:
                messages.append(f"⏰ 已工作 {duration:.1f} 小時，建議休息一下")
        except Exception:
            pass
    else:
        state["session_start"] = now.isoformat()

    return " | ".join(messages) if messages else None


# =============================================================================
# Main
# =============================================================================


def main():
    start_time = time.time()
    try:
        raw_input = sys.stdin.read()
        if not raw_input.strip():
            return

        data = json.loads(raw_input)
        prompt = data.get("prompt", "")
        cwd = data.get("cwd", "")
        session_id = data.get("session_id", "")

        # Load state
        state = load_state()
        state["prompt_count"] = state.get("prompt_count", 0) + 1

        messages = []

        # Log the prompt
        if prompt:
            log_prompt(cwd, prompt)

        # Feature 1: Check for dangerous patterns
        warning = check_dangerous_patterns(prompt)
        if warning:
            messages.append(f"⚠️ {warning} - 請確認這是你想要的操作")

        # Feature 8: Token estimation warning (check early)
        token_warning = check_token_heavy(prompt)
        if token_warning:
            messages.append(token_warning)

        # Feature 3: Suggest skill if applicable
        skill_suggestion = suggest_skill(prompt)
        if skill_suggestion:
            messages.append(skill_suggestion)

        # Feature 10: Advanced pattern detection
        pattern_matches = detect_patterns(prompt)
        pattern_suggestion = format_suggestions(pattern_matches)
        if pattern_suggestion and not skill_suggestion:  # Avoid duplicate suggestions
            messages.append(pattern_suggestion)

        # Feature 5: Smart context loading (first few prompts only)
        if state.get("prompt_count", 0) <= 3:
            context_suggestion = check_large_project(cwd, state)
            if context_suggestion:
                messages.append(context_suggestion)

        # Feature 6: Git status reminder
        git_reminder = check_git_status(cwd, state)
        if git_reminder:
            messages.append(git_reminder)

        # Feature 7: Similar prompt detection
        similar_warning = check_similar_prompt(prompt, state)
        if similar_warning:
            messages.append(similar_warning)

        # Feature 9: Time reminder (limit frequency)
        if state.get("prompt_count", 0) % 10 == 0:  # Every 10 prompts
            time_reminder = check_time_reminder(state)
            if time_reminder:
                messages.append(time_reminder)

        # Save state
        save_state(state)

        # Output response if there are messages
        if messages:
            response = {
                "continue": True,
                "systemMessage": "\n".join(messages),
            }
            print(json.dumps(response))

        # Log metrics and events
        execution_time_ms = (time.time() - start_time) * 1000
        log_hook_metrics(
            hook_name="user_prompt",
            event_type="UserPromptSubmit",
            execution_time_ms=execution_time_ms,
            session_id=session_id,
            success=True,
            metadata={
                "prompt_length": len(prompt),
                "estimated_tokens": estimate_tokens(prompt),
                "messages_count": len(messages),
                "patterns_detected": len(pattern_matches) if pattern_matches else 0,
            },
        )

        # Log event for dashboard
        log_hook_event(
            event_type="UserPromptSubmit",
            hook_name="user_prompt",
            session_id=session_id,
            cwd=cwd,
            metadata={
                "prompt_preview": prompt[:100] if prompt else "",
                "suggestions": messages,
            },
        )

    except (json.JSONDecodeError, Exception):
        # Log failed execution
        execution_time_ms = (time.time() - start_time) * 1000
        log_hook_metrics(
            hook_name="user_prompt",
            event_type="UserPromptSubmit",
            execution_time_ms=execution_time_ms,
            success=False,
        )


if __name__ == "__main__":
    main()
