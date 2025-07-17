#!/usr/bin/env python3
"""Write-good processor for markdown linting."""

import subprocess
import sys


def process_write_good_files(file_path):
    """Process markdown files with write-good linter."""
    try:
        result = subprocess.run(
            ["write-good", file_path], capture_output=True, text=True
        )
        if result.returncode == 0:
            print(f"📝 Write-good check passed for {file_path}", file=sys.stderr)
        else:
            # Send write-good suggestions to Claude via stderr and exit code 2
            print(
                f"Write-good found issues in {file_path}:\n{result.stdout.strip()}",
                file=sys.stderr,
            )
            sys.exit(2)  # Exit code 2 passes stderr to Claude for automatic processing
    except FileNotFoundError:
        print(
            "ERROR: write-good not found. Install with: npm install -g write-good",
            file=sys.stderr,
        )
        sys.exit(2)
