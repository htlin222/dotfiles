#!/usr/bin/env python3
"""
Quicktype wrapper script for generating types from JSON files.
"""

import argparse
import os
import subprocess
import sys


LANG_MAP = {
    "ts": "ts",
    "typescript": "ts",
    "go": "go",
    "golang": "go",
    "py": "py",
    "python": "py",
    "rs": "rs",
    "rust": "rs",
    "swift": "swift",
    "kotlin": "kotlin",
    "kt": "kotlin",
}


def main():
    parser = argparse.ArgumentParser(description="Generate types from JSON")
    parser.add_argument("file", help="JSON file path or URL")
    parser.add_argument("--lang", "-l", default="ts", help="Target language")
    parser.add_argument("--out", "-o", help="Output file path")
    parser.add_argument("--top-level", "-t", default="Root", help="Top-level type name")
    args = parser.parse_args()

    # Normalize language
    lang = LANG_MAP.get(args.lang.lower(), args.lang)

    # Check file exists (if not URL)
    if not args.file.startswith(("http://", "https://")):
        if not os.path.isfile(args.file):
            print(f"Error: File not found: {args.file}", file=sys.stderr)
            sys.exit(1)

    # Build command
    cmd = [
        "quicktype",
        "--lang",
        lang,
        "--just-types",
        "--top-level",
        args.top_level,
        args.file,
    ]

    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)

        if result.returncode != 0:
            print(f"Error: {result.stderr}", file=sys.stderr)
            sys.exit(1)

        output = result.stdout

        if args.out:
            with open(args.out, "w") as f:
                f.write(output)
            print(f"Types written to: {args.out}")
        else:
            print(output)

    except subprocess.TimeoutExpired:
        print("Error: Timeout processing file", file=sys.stderr)
        sys.exit(1)
    except FileNotFoundError:
        print(
            "Error: quicktype not installed. Run: pnpm add -g quicktype",
            file=sys.stderr,
        )
        sys.exit(1)


if __name__ == "__main__":
    main()
