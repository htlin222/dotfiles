#!/usr/bin/env python3
"""Biome processor for formatting and linting JavaScript/TypeScript files."""

import subprocess
import sys


def process_biome_files(file_path):
    """Process files with Biome formatter and linter."""
    try:
        # Run Biome format
        format_result = subprocess.run(
            ["biome", "format", file_path, "--write"], capture_output=True, text=True
        )
        if format_result.returncode == 0:
            print(f"✨ Formatted {file_path} with Biome", file=sys.stderr)
        else:
            print(
                f"⚠️  Biome format failed: {format_result.stderr.strip()}",
                file=sys.stderr,
            )

        # Run Biome check with --write to apply fixes
        check_result = subprocess.run(
            ["biome", "check", file_path, "--write"],
            capture_output=True,
            text=True,
        )
        if check_result.returncode == 0:
            if check_result.stdout and "Fixed" in check_result.stdout:
                # If Biome fixed issues, send details to Claude via exit code 2
                print(
                    f"Biome fixed issues in {file_path}:\n{check_result.stdout.strip()}",
                    file=sys.stderr,
                )
                sys.exit(
                    2
                )  # Exit code 2 passes stderr to Claude for automatic processing
            else:
                print(f"🔍 No linting issues in {file_path}", file=sys.stderr)
        else:
            # Send Biome linting issues to Claude via stderr and exit code 2
            print(
                f"Biome found issues in {file_path}:\n{check_result.stderr.strip()}",
                file=sys.stderr,
            )
            sys.exit(2)  # Exit code 2 passes stderr to Claude for automatic processing

    except FileNotFoundError:
        print(
            "ERROR: biome not found. Install with: npm install -g @biomejs/biome",
            file=sys.stderr,
        )


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: biome_processor.py <file_path>", file=sys.stderr)
        sys.exit(1)
    process_biome_files(sys.argv[1])
