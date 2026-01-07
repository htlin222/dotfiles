#!/usr/bin/env python3
"""
Notification hook - Handle Claude notifications with TTS.

Triggers: When Claude sends notifications (waiting for input, etc.)
"""

import json
import sys

# Import TTS utility
from tts import notify_notification


def main():
    try:
        raw_input = sys.stdin.read()
        if not raw_input.strip():
            notify_notification()
            return

        data = json.loads(raw_input)
        title = data.get("title", "")
        body = data.get("body", "")

        # TTS notification
        notify_notification(title, body)

    except (json.JSONDecodeError, Exception):
        notify_notification()


if __name__ == "__main__":
    main()
