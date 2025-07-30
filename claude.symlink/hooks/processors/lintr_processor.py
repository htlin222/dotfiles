#!/usr/bin/env python3
"""R processor for lintr linting."""

import subprocess
import sys


def process_r_files(file_path):
    """Process R files with lintr linter."""
    try:
        # Run lintr
        result = subprocess.run(
            ["Rscript", "-e", f"lintr::lint('{file_path}')"],
            capture_output=True,
            text=True,
        )

        if result.returncode == 0:
            if result.stdout and result.stdout.strip():
                # lintr found issues - send to Claude via exit code 2
                print(
                    f"lintr found issues in {file_path}:\n{result.stdout.strip()}",
                    file=sys.stderr,
                )
                sys.exit(
                    2
                )  # Exit code 2 passes stderr to Claude for automatic processing
            else:
                print(f"✅ No linting issues in {file_path}", file=sys.stderr)
        else:
            # Check if the error is due to missing package
            if (
                "could not find function" in result.stderr
                or "there is no package called" in result.stderr
            ):
                print(
                    "ERROR: lintr package not found. Install with: Rscript -e 'install.packages(\"lintr\")'",
                    file=sys.stderr,
                )
            else:
                # Other errors
                print(
                    f"⚠️  lintr failed: {result.stderr.strip()}",
                    file=sys.stderr,
                )

    except FileNotFoundError:
        print(
            "ERROR: Rscript not found. Install R from: https://www.r-project.org/",
            file=sys.stderr,
        )


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: lintr_processor.py <file_path>", file=sys.stderr)
        sys.exit(1)
    process_r_files(sys.argv[1])
