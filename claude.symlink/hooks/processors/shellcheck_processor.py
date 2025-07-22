#!/usr/bin/env python3
"""ShellCheck processor for bash and shell script linting."""

import subprocess
import sys


def process_shellcheck_files(file_path):
    """Process shell scripts with ShellCheck linter."""
    try:
        # Run ShellCheck linter
        check_result = subprocess.run(
            ["shellcheck", "-f", "gcc", file_path],
            capture_output=True,
            text=True,
        )

        if check_result.returncode == 0:
            print(f"✅ No issues in {file_path}", file=sys.stderr)
        else:
            # Send issues to Claude via stderr and exit code 2
            print(
                f"ShellCheck found issues in {file_path}:\n{check_result.stdout.strip()}",
                file=sys.stderr,
            )
            sys.exit(2)  # Exit code 2 passes stderr to Claude

    except FileNotFoundError:
        print(
            "ERROR: shellcheck not found. Install with: brew install shellcheck",
            file=sys.stderr,
        )


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: shellcheck_processor.py <file_path>", file=sys.stderr)
        sys.exit(1)
    process_shellcheck_files(sys.argv[1])
