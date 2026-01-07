#!/usr/bin/env python3
"""Prettier processor for formatting files."""

import subprocess
import sys


def process_prettier_files(file_path):
    """Process files with Prettier - check only, no auto-fix."""
    try:
        result = subprocess.run(
            ["prettier", "--check", file_path], capture_output=True, text=True
        )
        if result.returncode == 0:
            print(f"✅ {file_path}: Prettier checks passed", file=sys.stderr)
        else:
            print(
                f"✨ {file_path}: Prettier 格式問題 - 需要格式化",
                file=sys.stderr,
            )
            sys.exit(2)  # Exit code 2 passes stderr to Claude
    except FileNotFoundError:
        print(
            "ERROR: prettier not found. Install with: npm install -g prettier",
            file=sys.stderr,
        )
