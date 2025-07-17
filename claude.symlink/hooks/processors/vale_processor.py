#!/usr/bin/env python3
"""Vale processor for markdown linting."""

import subprocess
import sys


def process_vale_files(file_path):
    """Process markdown files with Vale linter."""
    try:
        result = subprocess.run(["vale", file_path], capture_output=True, text=True)
        if result.returncode == 0:
            print(f"📝 Vale check passed for {file_path}", file=sys.stderr)
        else:
            # Send Vale suggestions to Claude via stderr and exit code 2
            print(
                f"Vale found issues in {file_path}:\n{result.stdout.strip()}",
                file=sys.stderr,
            )
            sys.exit(2)  # Exit code 2 passes stderr to Claude for automatic processing
    except FileNotFoundError:
        print(
            "ERROR: vale not found. Install from: https://vale.sh/docs/vale-cli/installation/",
            file=sys.stderr,
        )
        sys.exit(2)
