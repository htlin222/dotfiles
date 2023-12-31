#!/usr/bin/env python3
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Refresh the inbox list
# @raycast.mode silent
# @raycast.packageName Browsing
# Optional parameters:
# @raycast.icon ⛲
# Documentation:
# @raycast.author Hsieh.Ting Lin
# @raycast.description Refresh the inbox list by date
import os
from datetime import datetime
from datetime import timedelta

current_date_time = datetime.now()
string_date_time = current_date_time.strftime("%Y-%m-%d")


def generate_list():
    # Get all markdown files in current directory
    folder = os.path.expanduser("~/Dropbox/inbox/")
    os.chdir(folder)
    files = [f for f in os.listdir(folder) if f.endswith(".md") and f != "index.md"]

    # Sort files by date created, from newest to oldest
    files.sort(key=lambda f: os.path.getctime(f), reverse=True)
    # Group files into "today", "yesterday", and "previous" categories
    now = datetime.now()
    today_files = []
    yesterday_files = []
    week_files = []
    for f in files:
        file_time = datetime.fromtimestamp(os.path.getctime(f))
        if file_time.date() == now.date():
            today_files.append(
                "- {} [[{}]]".format(
                    file_time.strftime("%H:%M"), os.path.splitext(f)[0]
                )
            )
        elif file_time.date() == (now - timedelta(days=1)).date():
            yesterday_files.append(
                "- {} [[{}]]".format(
                    file_time.strftime("%H:%M"), os.path.splitext(f)[0]
                )
            )
        elif file_time.date() >= (now - timedelta(days=20)).date():
            week_files.append(
                "- {} [[{}]]".format(
                    file_time.strftime("%Y-%m-%d"), os.path.splitext(f)[0]
                )
            )
        else:
            pass

    # Write the formatted files to "inbox.md"
    heading = "inbox"
    with open("index.md", "w") as f:
        new_front_and_heading = f"""---
title: "{heading}"
date: "{string_date_time}"
enableToc: true
---

> [!info]
>
> 👉 Go to [[../Medical/index.md|花園大門口]]

"""
        f.write(new_front_and_heading)
        f.write("# 最近編輯的檔案\n\n")
        if today_files:
            f.write(f"## 今天 {string_date_time}\n\n")
            f.write("\n".join(today_files))
            f.write("\n\n")
        if yesterday_files:
            f.write("## 昨天\n\n")
            f.write("\n".join(yesterday_files))
            f.write("\n\n")
        if week_files:
            f.write("## 之前\n\n")
            f.write("\n".join(week_files))


if __name__ == "__main__":
    generate_list()
    # print("Refresh Inbox Index")
