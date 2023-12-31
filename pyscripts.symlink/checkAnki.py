#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# title: checkAnki
# date: "2023-10-06"
# author: Hsieh-Ting Lin, the Lizard 🦎
import subprocess
import time

import psutil

# Check if Anki is already running
anki_running = False
for proc in psutil.process_iter():
    try:
        if proc.name() == "Anki":
            anki_running = True
            break
    except psutil.NoSuchProcess:
        pass

# Open Anki if it is not already running
if not anki_running:
    subprocess.call(["/usr/bin/open", "/Applications/Anki.app"])
    time.sleep(5)
    subprocess.call([
        "/usr/bin/osascript",
        "-e",
        'tell application "System Events" to set visible of process "Anki" to false',
    ])
