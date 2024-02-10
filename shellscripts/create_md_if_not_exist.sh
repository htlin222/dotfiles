#!/bin/bash
# Author: Hsieh-Ting Lin
# Title: "create_md_if_not_exist"
# Date: "2024-02-10"
# Version: 1.0.0
# Notes:

# 檢查是否提供了目錄作為參數
if [ $# -eq 0 ]; then
	echo "請提供一個目錄作為參數。"
	exit 1
fi

# 讀取提供的目錄路徑
FOLDER_PATH=$1

# 檢查目錄是否存在
if [ ! -d "$FOLDER_PATH" ]; then
	echo "提供的路徑不是一個目錄：$FOLDER_PATH"
	exit 1
fi

# 遍歷目錄中的每個文件
for file in "$FOLDER_PATH"/*; do
	if [ -f "$file" ]; then # 確保是文件
		filename=$(basename -- "$file")
		extension="${filename##*.}"
		filename_without_ext="${filename%.*}"

		# 忽略特定擴展名的文件
		if [[ "$extension" == "py" || "$extension" == "sh" || "$extension" == "txt" || "$extension" == "md" ]]; then
			continue
		fi

		# 檢查同名的 .md 文件是否存在
		if [ ! -f "$FOLDER_PATH/$filename_without_ext.md" ]; then
			# 如果不存在，則創建一個空的 .md 文件
			touch "$FOLDER_PATH/$filename_without_ext.md"
			echo "↘ 創建了文件：$FOLDER_PATH/$filename_without_ext.md"
		fi
	fi
done
