#!/usr/bin/env python3
"""BibTeX processor for bibtex-tidy formatting and validation."""

import subprocess
import sys


def process_bibtex_files(file_path):
    """Process BibTeX files with bibtex-tidy formatter."""
    try:
        # Run bibtex-tidy with common options
        # --curly: Wrap values in curly braces
        # --numeric: Make all numeric values unquoted
        # --space: Use spaces for indentation (instead of tabs)
        # --align: Align the equals signs
        # --sort: Sort entries by key
        # --duplicates: Remove duplicate entries
        # --merge: Merge duplicate entries
        # --strip-comments: Remove comments
        # --trailing-commas: Remove trailing commas
        # --encode-urls: Encode URLs
        # --remove-empty-fields: Remove empty fields
        # --max-authors: Limit authors (optional, commented out)
        result = subprocess.run(
            [
                "bibtex-tidy",
                "--curly",
                "--numeric",
                "--space=2",
                "--align=13",
                "--sort",
                "--duplicates=key",
                "--merge=combine",
                "--strip-comments",
                "--trailing-commas",
                "--encode-urls",
                "--remove-empty-fields",
                "--quiet",
                "--modify",  # Modify the file in place
                file_path,
            ],
            capture_output=True,
            text=True,
        )

        if result.returncode == 0:
            # Check if any changes were made by examining stdout
            if result.stdout and "tidied" in result.stdout.lower():
                print(
                    f"📚 BibTeX-tidy formatted {file_path}:\n{result.stdout.strip()}",
                    file=sys.stderr,
                )
                sys.exit(2)  # Exit code 2 passes stderr to Claude
            else:
                print(f"✨ Formatted {file_path} with bibtex-tidy", file=sys.stderr)
        else:
            # bibtex-tidy found issues
            error_msg = (
                result.stderr.strip() if result.stderr else result.stdout.strip()
            )
            print(
                f"⚠️  bibtex-tidy found issues in {file_path}:\n{error_msg}",
                file=sys.stderr,
            )
            sys.exit(2)  # Exit code 2 passes stderr to Claude for processing

    except FileNotFoundError:
        print(
            "ERROR: bibtex-tidy not found. Install with: npm install -g bibtex-tidy",
            file=sys.stderr,
        )


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: bibtex_processor.py <file_path>", file=sys.stderr)
        sys.exit(1)
    process_bibtex_files(sys.argv[1])
