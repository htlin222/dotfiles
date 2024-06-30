#!/bin/bash
# title: "batch_add_queue_markdown_to_anki"
# author: Hsieh-Ting Lin
# date: "2024-06-09"
# version: 1.0.0
# description: search all the markdown edit in past 24 hours and copy to queue folder then sent them to Anki connect, delete the original files after done
# --END-- #

# 搜索並複製符合條件的Markdown文件
find ~/Dropbox/Medical -name "*.md" -type f -mtime -1 -exec grep -l "ANKI" {} \; -exec cp "{}" ~/Dropbox/tmp/queue \;

# 遍歷目標目錄中的所有Markdown文件並執行Python腳本
for file in ~/Dropbox/tmp/queue/*.md; do
	# /Users/mac/.pyenv/versions/automator/bin/python ~/pyscripts/add_md_to_anki.py "$file"
	~/bin/md_to_anki/md_to_anki -f "$file"
done

# rm -f ~/Dropbox/tmp/queue/*.md
