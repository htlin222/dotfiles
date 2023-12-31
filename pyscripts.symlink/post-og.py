#!/Users/htlin/.pyenv/versions/automator/bin/python
# -*- coding: utf-8 -*-
# title: post-og
# date: "2023-09-22"
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Generate the OpenGraph for the post
# @raycast.mode silent
# @raycast.packageName Browsing
# Optional parameters:
# @raycast.icon 🌅
# Documentation:
# @raycast.author Hsieh.Ting Lin
# @raycast.description Generate the OpenGraph
import os
import subprocess

import pyperclip

# Function to copy image to clipboard (MacOS)
theme_path = os.path.expanduser("~/Dropbox/slides/themes/medium.css")
tmp_md_path = os.path.expanduser("/tmp/tmp.md")
output_png_path = os.path.expanduser("/tmp/output.png")
engine = os.path.expanduser("~/Dropbox/slides/engine.js")


def copy_image_to_clipboard(image_path):
    if os.uname().sysname == "Darwin":  # MacOS
        subprocess.run([
            "osascript",
            "-e",
            f'set the clipboard to (read "{image_path}" as JPEG picture)',
        ])
    else:
        print("Clipboard operation not supported on this OS.")


def run_macos_notification(title, body):
    command = (
        f'osascript -e \'display notification with title "{title}" subtitle "{body}"\''
    )
    subprocess.run(command, shell=True)


# Step 1: Grab text from the clipboard
clipboard_text = pyperclip.paste()

# Step 2: Create a temp file called tmp.md manually

with open(tmp_md_path, "w") as f:
    # Step 3: Add the text from the clipboard
    header = "## 蜥蜴花園 🪴"
    html_string = """
<hr>
<div class="profile_container">
  <img src="https://i.imgur.com/jsR0kcJ.jpg" alt="Example Image" class="LLQ">
  <div class="text">
    <p> 林協霆 🦎 The Lizard</p>
    <p>@physician.tw</p>
  </div>
</div>
"""
    f.write(f"{header}\n# {clipboard_text}\n{html_string}")

# Step 4: Run the subprocess to generate image
run_macos_notification("👟 Running Marp for Og", "🪴 Be patient")
subprocess.run([
    "marp",
    "--theme",
    theme_path,
    tmp_md_path,
    "--engine",
    engine,
    "--html",
    "-o",
    output_png_path,
])

# Step 5: Copy the output image to clipboard
if os.path.exists(output_png_path):
    copy_image_to_clipboard(output_png_path)
    run_macos_notification("👍讚", "🌁 in your 📋")
else:
    print("Failed to generate output.png")

# Optional: Remove tmp.md if you don't need it anymore
os.remove(tmp_md_path)
os.remove(output_png_path)
