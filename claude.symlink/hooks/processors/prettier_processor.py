#!/usr/bin/env python3
"""Prettier processor for formatting files."""

import subprocess
import sys


def process_prettier_files(file_path):
    """Process files with Prettier formatter."""
    try:
        result = subprocess.run(
            ["prettier", "--write", file_path], capture_output=True, text=True
        )
        if result.returncode == 0:
            print(f"✨ Formatted {file_path} with Prettier", file=sys.stderr)
        else:
            print(f"⚠️  Prettier failed: {result.stderr.strip()}", file=sys.stderr)
    except FileNotFoundError:
        print(
            "ERROR: prettier not found. Install with: npm install -g prettier",
            file=sys.stderr,
        )
