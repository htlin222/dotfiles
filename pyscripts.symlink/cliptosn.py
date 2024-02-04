#!/Users/htlin/.pyenv/versions/automator/bin/python
# -*- coding: utf-8 -*-
# title: cliptosn
# date: "2024-02-04"
# @raycast.title Clipboard to Simplenote with Anki tag
# @raycast.author HTLin the 🦎
# @raycast.authorURL https://github.com/htlin222
# @raycast.description Take the clipboard to simplenote
# @raycast.icon 📋
# @raycast.mode silent
# @raycast.packageName System
# @raycast.schemaVersion 1
# disc: take the clipboard contnet to simplenote via simplenote api


import os
import subprocess

import simplenote
from dotenv import load_dotenv
from jaraco import clipboard

# 加載 .env 檔案
load_dotenv()

SIMPLENOTE_EMAIL = os.getenv("SIMPLENOTE_EMAIL")
SIMPLENOTE_PASSWORD = os.getenv("SIMPLENOTE_PASSWORD")


def run_macos_notification(title, body):
    title = title.replace("'", "_")
    body = body.replace("'", "_")
    command = (
        f'osascript -e \'display notification with title "{title}" subtitle "{body}"\''
    )
    subprocess.run(command, shell=True)


def main():
    note_store = simplenote.Simplenote(SIMPLENOTE_EMAIL, SIMPLENOTE_PASSWORD)
    note_body = clipboard.paste()
    if note_body is None:
        run_macos_notification("剪貼板中沒有內容", "Check it")
    else:
        note_body = note_body.lstrip("\n")
        note_store.add_note({"content": note_body, "tags": ["anki"]})
        run_macos_notification("已將文字加入成一則筆記", note_body)


if __name__ == "__main__":
    main()
