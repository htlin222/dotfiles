#!/usr/bin/env python3
"""ESLint processor for JavaScript/TypeScript linting."""

import subprocess
import sys


def process_eslint_files(file_path):
    """Process JavaScript/TypeScript files with ESLint."""
    try:
        # Run ESLint with --fix to auto-fix issues
        result = subprocess.run(
            ["eslint", "--fix", file_path], capture_output=True, text=True
        )

        if result.returncode == 0:
            print(f"✅ ESLint check passed for {file_path}", file=sys.stderr)
        else:
            # Send ESLint issues to Claude via stderr and exit code 2
            error_output = (
                result.stdout.strip() if result.stdout else result.stderr.strip()
            )
            print(
                f"ESLint found issues in {file_path}:\n{error_output}", file=sys.stderr
            )
            sys.exit(2)  # Exit code 2 passes stderr to Claude for automatic processing

    except FileNotFoundError:
        print(
            "ERROR: eslint not found. Install with: npm install -g eslint",
            file=sys.stderr,
        )
        sys.exit(2)
