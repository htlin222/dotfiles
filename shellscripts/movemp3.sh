#!/bin/bash
# Author: Hsieh-Ting Lin
# title: "movemp3"
# date created: "2023-12-17"

# 搜索并移动.mp3文件
find "$HOME/dropbox/scripts/my_openai/" -type f -name "*.mp3" -exec mv {} "$HOME/Library/CloudStorage/GoogleDrive-ppoiu87@gmail.com/我的雲端硬碟/audio/" \;

# /Users/mac/Library/CloudStorage/GoogleDrive-ppoiu87@gmail.com/我的雲端硬碟/audio/
