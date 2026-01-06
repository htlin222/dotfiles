#!/usr/bin/env python3
"""
Notification hook - only voice alert, no ntfy (Stop hook handles ntfy).
Triggers: permission needed or idle 60+ seconds.
"""

import json
import sys


def main():
    try:
        raw_input = sys.stdin.read()
        if not raw_input.strip():
            return

        data = json.loads(raw_input)
        message = data.get("message", "")

        if message:
            # Audio disabled - ntfy handled by Stop hook
            pass

    except (json.JSONDecodeError, Exception):
        pass


if __name__ == "__main__":
    main()
