#!/usr/bin/env python3
"""
PostToolUse hook - Process files after Claude edits them.

Features:
1. File Edit Tracker - Log all file edits to ~/.claude/logs/edits.jsonl
2. Auto Formatting - Run formatters (Biome, Prettier, Ruff, etc.)
3. Build Checker - Run typecheck/lint after edits, warn if errors > threshold
4. Risky Pattern Detector - Detect risky code patterns and warn
"""

import json
import os
import re
import subprocess
import sys
from datetime import datetime

# Import processors
from processors import (
    process_bibtex_files,
    process_biome_files,
    process_prettier_files,
    process_python_files,
    process_r_files,
    process_vale_files,
)

# =============================================================================
# Configuration
# =============================================================================

LOG_DIR = os.path.expanduser("~/.claude/logs")
EDIT_LOG_FILE = os.path.join(LOG_DIR, "edits.jsonl")
BASH_LOG_FILE = os.path.join(LOG_DIR, "bash_commands.jsonl")
BUILD_ERROR_THRESHOLD = 5  # Warn if errors exceed this

# Directories to always skip (build outputs, dependencies, etc.)
SKIP_DIRS = {
    "node_modules",
    "dist",
    "build",
    ".next",
    ".nuxt",
    "__pycache__",
    ".venv",
    "venv",
    ".git",
    "coverage",
    ".cache",
    "out",
    ".output",
}


def is_gitignored(file_path: str, cwd: str = "") -> bool:
    """Check if file is gitignored or in a skip directory."""
    # Check skip directories first (fast path)
    path_parts = file_path.replace("\\", "/").split("/")
    if any(part in SKIP_DIRS for part in path_parts):
        return True

    # Use git check-ignore for accurate gitignore detection
    try:
        result = subprocess.run(
            ["git", "check-ignore", "-q", file_path],
            cwd=cwd or os.path.dirname(file_path) or ".",
            capture_output=True,
            timeout=5,
        )
        return result.returncode == 0  # 0 means ignored
    except Exception:
        return False


# File type mappings
BIOME_EXTS = {".js", ".jsx", ".tsx", ".ts", ".json", ".css"}
PRETTIER_EXTS = {
    ".html",
    ".md",
    ".qmd",
    ".mdx",
    ".scss",
    ".less",
    ".vue",
    ".yaml",
    ".yml",
}
PYTHON_EXTS = {".py", ".pyi"}
BIBTEX_EXTS = {".bib"}
R_EXTS = {".R", ".r"}
MARKDOWN_EXTS = {".md", ".mdx", ".qmd"}
TYPESCRIPT_EXTS = {".ts", ".tsx"}

# Risky patterns to detect (pattern, description, severity)
RISKY_PATTERNS = [
    # Async without error handling
    (
        r"async\s+(?:function|def|\w+\s*=\s*async)\s+[^}]+(?<!try\s*\{)",
        "Async 函數可能缺少 try-catch",
        "medium",
    ),
    # Hardcoded credentials
    (
        r'(?:password|secret|api_key|apikey|token)\s*[=:]\s*["\'][^"\']{8,}["\']',
        "可能的硬編碼憑證",
        "high",
    ),
    # Direct SQL queries (SQL injection risk)
    (
        r'(?:execute|query)\s*\(\s*f["\']|\.format\s*\(.*(?:SELECT|INSERT|UPDATE|DELETE)',
        "可能的 SQL 注入風險",
        "high",
    ),
    # eval/exec usage
    (r"\b(?:eval|exec)\s*\(", "使用 eval/exec 有安全風險", "high"),
    # Console.log in production code (not test files)
    (r"console\.log\s*\(", "殘留 console.log", "low"),
    # TODO/FIXME comments
    (r"(?://|#)\s*(?:TODO|FIXME|XXX|HACK):", "未完成的 TODO/FIXME", "low"),
    # Disabled eslint/type checks
    (
        r"(?:eslint-disable|@ts-ignore|@ts-nocheck|type:\s*ignore|noqa)",
        "停用的 lint/type 檢查",
        "medium",
    ),
]


# =============================================================================
# Feature 1: File Edit Tracker
# =============================================================================


def log_file_edit(file_path: str, tool_name: str, cwd: str):
    """Log file edit to edits.jsonl."""
    os.makedirs(LOG_DIR, exist_ok=True)

    entry = {
        "timestamp": datetime.now().isoformat(),
        "file": file_path,
        "tool": tool_name,
        "cwd": cwd,
        "project": os.path.basename(cwd) if cwd else "",
    }

    with open(EDIT_LOG_FILE, "a", encoding="utf-8") as f:
        f.write(json.dumps(entry, ensure_ascii=False) + "\n")


def log_bash_command(command: str, cwd: str, exit_code: int | None = None):
    """Log bash command to bash_commands.jsonl for audit trail."""
    os.makedirs(LOG_DIR, exist_ok=True)

    # Truncate very long commands
    truncated_cmd = command[:500] + "..." if len(command) > 500 else command

    entry = {
        "timestamp": datetime.now().isoformat(),
        "command": truncated_cmd,
        "cwd": cwd,
        "project": os.path.basename(cwd) if cwd else "",
        "exit_code": exit_code,
    }

    try:
        with open(BASH_LOG_FILE, "a", encoding="utf-8") as f:
            f.write(json.dumps(entry, ensure_ascii=False) + "\n")
    except Exception:
        pass


# =============================================================================
# Feature 2: Build Checker
# =============================================================================


def check_typescript_build(cwd: str) -> tuple[bool, int, str]:
    """Run TypeScript type check. Returns (success, error_count, output)."""
    if not cwd or not os.path.exists(os.path.join(cwd, "package.json")):
        return True, 0, ""

    try:
        # Try pnpm first, then npm
        for cmd in [
            ["pnpm", "typecheck"],
            ["pnpm", "tsc", "--noEmit"],
            ["npx", "tsc", "--noEmit"],
        ]:
            result = subprocess.run(
                cmd,
                cwd=cwd,
                capture_output=True,
                text=True,
                timeout=60,
            )
            if result.returncode == 0:
                return True, 0, ""

            # Count errors
            error_count = len(
                re.findall(r"error TS\d+:", result.stdout + result.stderr)
            )
            return False, error_count, result.stderr[:500]
    except (subprocess.TimeoutExpired, FileNotFoundError):
        pass

    return True, 0, ""


def check_python_lint(file_path: str) -> tuple[bool, int, str]:
    """Run Ruff check on Python file. Returns (success, error_count, output)."""
    try:
        result = subprocess.run(
            ["ruff", "check", file_path, "--output-format=concise"],
            capture_output=True,
            text=True,
            timeout=30,
        )
        if result.returncode == 0:
            return True, 0, ""

        error_count = (
            len(result.stdout.strip().split("\n")) if result.stdout.strip() else 0
        )
        return False, error_count, result.stdout[:500]
    except (subprocess.TimeoutExpired, FileNotFoundError):
        pass

    return True, 0, ""


# =============================================================================
# Feature 3: Risky Pattern Detector
# =============================================================================


def detect_risky_patterns(file_path: str) -> list[dict]:
    """Detect risky patterns in file. Returns list of findings."""
    findings = []

    # Skip test files for some patterns
    is_test_file = any(
        x in file_path.lower() for x in ["test", "spec", "__test__", ".test.", "_test."]
    )

    try:
        with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()

        for pattern, description, severity in RISKY_PATTERNS:
            # Skip console.log detection for test files
            if "console.log" in pattern and is_test_file:
                continue

            matches = re.findall(pattern, content, re.IGNORECASE | re.MULTILINE)
            if matches:
                findings.append(
                    {
                        "pattern": description,
                        "severity": severity,
                        "count": len(matches),
                    }
                )
    except Exception:
        pass

    return findings


# =============================================================================
# Main Processing
# =============================================================================


def main():
    # Read input
    raw_input = sys.stdin.read()

    # Parse JSON to get tool info
    try:
        data = json.loads(raw_input)
        tool_name = data.get("tool_name", "Unknown")
        tool_input = data.get("tool_input", {})
        tool_result = data.get("tool_result", {})
        cwd = data.get("cwd", "")
    except json.JSONDecodeError:
        tool_name = "Unknown"
        tool_input = {}
        tool_result = {}
        cwd = ""

    # Feature: Log Bash commands for audit trail
    if tool_name == "Bash":
        command = tool_input.get("command", "")
        exit_code = tool_result.get("exit_code") if isinstance(tool_result, dict) else None
        if command:
            log_bash_command(command, cwd, exit_code)

    # Find file paths using regex
    pattern = r'"(?:filePath|file_path)"\s*:\s*"([^"]+)"'
    file_paths = re.findall(pattern, raw_input)

    warnings = []
    ts_files_edited = False

    # Process found paths
    for file_path in file_paths:
        if not os.path.exists(file_path):
            continue

        _, ext = os.path.splitext(file_path)

        # Feature 1: Log the edit (always log, even for ignored files)
        log_file_edit(file_path, tool_name, cwd)

        # Skip gitignored files and build directories for linting
        if is_gitignored(file_path, cwd):
            continue

        # Feature 2: Track if TypeScript files were edited
        if ext in TYPESCRIPT_EXTS:
            ts_files_edited = True

        # Feature 3: Detect risky patterns
        findings = detect_risky_patterns(file_path)
        for finding in findings:
            if finding["severity"] in ("high", "medium"):
                warnings.append(
                    f"⚠️ {os.path.basename(file_path)}: {finding['pattern']}"
                )

        # Run linters/formatters in check-only mode (no file modifications)
        if ext in BIOME_EXTS:
            process_biome_files(file_path)
        elif ext in PRETTIER_EXTS:
            process_prettier_files(file_path)
            if ext in MARKDOWN_EXTS:
                process_vale_files(file_path)
        elif ext in PYTHON_EXTS:
            process_python_files(file_path)
        elif ext in BIBTEX_EXTS:
            process_bibtex_files(file_path)
        elif ext in R_EXTS:
            process_r_files(file_path)

    # Feature 2: Run TypeScript build check if ts/tsx files were edited
    if ts_files_edited and cwd:
        success, error_count, _ = check_typescript_build(cwd)
        if not success and error_count > BUILD_ERROR_THRESHOLD:
            warnings.append(
                f"🔴 TypeScript: {error_count} type errors - 建議執行 /build-and-fix"
            )

    # Output response
    try:
        data = json.loads(raw_input)
        if warnings:
            # Add warnings as system message
            data["_warnings"] = warnings
            response = {
                "continue": True,
                "systemMessage": "\n".join(warnings[:5]),  # Limit to 5 warnings
            }
            print(json.dumps(response))
        else:
            print(json.dumps(data))
    except json.JSONDecodeError:
        cleaned = (
            raw_input.replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t")
        )
        print(cleaned)


if __name__ == "__main__":
    main()
