#!/bin/bash
# Author: Hsieh-Ting Lin
# title: "epubtxt"
# date created: "2023-12-19"
# 設定 EPUB 檔案所在的資料夾
FOLDER="/Users/htlin/Desktop/process.nosync"

# 設定轉換後的 EPUB 檔案應該移動到的資料夾
EPUB_FOLDER="$FOLDER/epub"

# 確保存放 EPUB 檔案的資料夾存在
mkdir -p "$EPUB_FOLDER"

# 嘗試切換到指定的資料夾
cd "$FOLDER" || {
	echo "無法切換到資料夾 $FOLDER。腳本退出。"
	exit 1
}

# 遍歷資料夾中的所有 EPUB 檔案
for file in *.epub; do
	# 檢查是否為檔案
	if [ -f "$file" ]; then
		# 獲取不包括副檔名的檔案名
		base_name=$(basename "$file" .epub)
		# 轉換成 TXT 檔案
		if [ -e /opt/homebrew/bin/ebook-convert ]; then
			/opt/homebrew/bin/ebook-convert "$file" "${base_name}.txt"
		else
			/usr/local/bin/ebook-convert "$file" "${base_name}.txt"
		fi
		mv "$file" "$EPUB_FOLDER/"

	fi
done
