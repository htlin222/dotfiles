#!/usr/bin/env python3
"""Python processor for Ruff formatting and linting."""

import subprocess
import sys


def process_python_files(file_path):
    """Process Python files with Ruff - check only, no auto-fix."""
    try:
        # Run Ruff format check (no --write, just diagnose)
        format_result = subprocess.run(
            ["ruff", "format", "--check", file_path], capture_output=True, text=True
        )
        format_issues = format_result.returncode != 0

        # Run Ruff lint check (no --fix, just diagnose)
        lint_result = subprocess.run(
            ["ruff", "check", file_path],
            capture_output=True,
            text=True,
        )
        lint_issues = lint_result.returncode != 0

        # Report issues to Claude
        if format_issues or lint_issues:
            issues = []
            if format_issues:
                issues.append("格式問題")
            if lint_issues:
                issues.append(f"Lint: {lint_result.stdout.strip()}")
            print(
                f"🐍 {file_path}: {'; '.join(issues)}",
                file=sys.stderr,
            )
            sys.exit(2)  # Exit code 2 passes stderr to Claude
        else:
            print(f"✅ {file_path}: Ruff checks passed", file=sys.stderr)

    except FileNotFoundError:
        print(
            "ERROR: ruff not found. Install with: pip install ruff",
            file=sys.stderr,
        )
