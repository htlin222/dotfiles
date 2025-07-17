#!/usr/bin/env python3
"""Python processor for Ruff formatting and linting."""

import subprocess
import sys


def process_python_files(file_path):
    """Process Python files with Ruff formatter and linter."""
    try:
        # Run Ruff format
        result = subprocess.run(
            ["ruff", "format", file_path], capture_output=True, text=True
        )
        if result.returncode == 0:
            print(f"🐍 Formatted {file_path} with Ruff", file=sys.stderr)
        else:
            print(
                f"⚠️  Ruff format failed: {result.stderr.strip()}",
                file=sys.stderr,
            )

        # Run Ruff check with fix
        result = subprocess.run(
            ["ruff", "check", "--fix", file_path],
            capture_output=True,
            text=True,
        )
        if result.returncode == 0:
            if result.stdout or result.stderr:
                # If Ruff fixed issues, send details to Claude via exit code 2
                print(
                    f"Ruff fixed issues in {file_path}:\n{result.stdout.strip()}",
                    file=sys.stderr,
                )
                sys.exit(
                    2
                )  # Exit code 2 passes stderr to Claude for automatic processing
            else:
                print(f"✅ No linting issues in {file_path}", file=sys.stderr)
        else:
            # Send Ruff linting issues to Claude via stderr and exit code 2
            print(
                f"Ruff found unfixable issues in {file_path}:\n{result.stdout.strip()}",
                file=sys.stderr,
            )
            sys.exit(2)  # Exit code 2 passes stderr to Claude for automatic processing

    except FileNotFoundError:
        print(
            "ERROR: ruff not found. Install with: pip install ruff",
            file=sys.stderr,
        )
