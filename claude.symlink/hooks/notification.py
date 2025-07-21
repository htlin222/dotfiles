#!/usr/bin/env python3

import json
import subprocess
import sys


def main():
    try:
        # Read JSON from stdin
        raw_input = sys.stdin.read()

        if not raw_input.strip():
            return

        # Parse JSON
        data = json.loads(raw_input)

        # Extract message from JSON
        message = data.get("message", "")

        if message:
            # Use macOS 'say' command to speak the message
            subprocess.run(["say", "--rate=200", message], check=False)

    except json.JSONDecodeError:
        # Silently ignore invalid JSON
        pass
    except Exception:
        # Silently ignore other errors to avoid disrupting the hook system
        pass


if __name__ == "__main__":
    main()
