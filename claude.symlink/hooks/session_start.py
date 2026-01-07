#!/usr/bin/env python3
"""
SessionStart hook - Load project context and set environment.
Triggers: session start, resume, clear, compact.
Uses CLAUDE_ENV_FILE to persist environment variables for the session.
"""

import json
import os
import sys


def main():
    try:
        raw_input = sys.stdin.read()
        if not raw_input.strip():
            return

        data = json.loads(raw_input)
        cwd = data.get("cwd", "")
        source = data.get("source", "startup")

        # Get project name from cwd
        project_name = os.path.basename(cwd) if cwd else "unknown"

        # Write environment variables if env file exists
        env_file = os.environ.get("CLAUDE_ENV_FILE", "")
        if env_file:
            with open(env_file, "a") as f:
                f.write(f"export PROJECT_NAME='{project_name}'\n")
                f.write(f"export SESSION_SOURCE='{source}'\n")

        # Output JSON response
        print(json.dumps({"continue": True, "systemMessage": "Success"}))

    except (json.JSONDecodeError, Exception):
        pass


if __name__ == "__main__":
    main()
