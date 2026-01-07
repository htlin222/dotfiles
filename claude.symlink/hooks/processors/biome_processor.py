#!/usr/bin/env python3
"""Biome processor for formatting and linting JavaScript/TypeScript files."""

import subprocess
import sys


def process_biome_files(file_path):
    """Process files with Biome - check only, no auto-fix."""
    try:
        # Run Biome check (no --write, just diagnose)
        check_result = subprocess.run(
            ["biome", "check", file_path],
            capture_output=True,
            text=True,
        )

        if check_result.returncode == 0:
            print(f"✅ {file_path}: Biome checks passed", file=sys.stderr)
        else:
            # Report issues to Claude
            output = check_result.stdout.strip() or check_result.stderr.strip()
            print(
                f"✨ {file_path}: Biome 發現問題:\n{output}",
                file=sys.stderr,
            )
            sys.exit(2)  # Exit code 2 passes stderr to Claude

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
