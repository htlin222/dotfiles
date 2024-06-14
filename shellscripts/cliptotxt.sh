#!/bin/bash
# Author: Hsieh-Ting Lin
# title: "cliptotxt"
# date created: "2023-12-18"

# 檢查是否提供了標題
if [ -z "$1" ]; then
	echo "請提供標題作為參數，例如：cliptotext.sh \"標題\""
	exit 1
fi

# 設定文件路徑
directory="$HOME/Dropbox/scripts/my_openai"
filename="$directory/$1.txt"

# 檢查目錄是否存在，如果不存在則創建它
if [ ! -d "$directory" ]; then
	mkdir -p "$directory"
fi

# 將剪貼板中的文本保存到文件
pbpaste >"$filename"

echo "文本已保存到 $filename"
exit 0
