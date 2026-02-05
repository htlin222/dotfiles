#!/bin/bash
# Author: Hsieh-Ting Lin
# title: "pptx_to_pdf"
# date created: "2023-11-16"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./shellscripts/lib.sh
source "$SCRIPT_DIR/lib.sh"

# 設定目錄
PDF_FOLDER="$HOME/Documents/10_PDF檔" # PDF 存放目錄
SOURCE_FOLDER="${PDF_FOLDER}"        # 使用 {} 進行變數替換
CONVERTED_FOLDER="${PDF_FOLDER}/converted"
LIBREOFFICE="/Applications/LibreOffice.app/Contents/MacOS/soffice"
LOCK_DIR="$PDF_FOLDER/locks" # 鎖檔目錄

# 檢查並創建必要目錄
mkdir -p "$PDF_FOLDER"
mkdir -p "$CONVERTED_FOLDER"
mkdir -p "$LOCK_DIR"

# 尋找當前目錄中的 .ppt 和 .pptx 檔案
FILES=$(find "$SOURCE_FOLDER" -maxdepth 1 -type f \( -name "*.ppt" -o -name "*.pptx" \))

if [ -z "$FILES" ]; then
  # 如果沒有找到檔案，以綠色文字輸出訊息
  echo "\033[0;32m在[10_PDF]裡沒有找到任何 .ppt 或 .pptx 檔案。\033[0m"
else
  if [[ ! -x "$LIBREOFFICE" ]]; then
    if command -v soffice >/dev/null 2>&1; then
      LIBREOFFICE="$(command -v soffice)"
    else
      echo "LibreOffice (soffice) not found." >&2
      exit 1
    fi
  fi
  # 如果找到檔案，則進行轉換
  echo "$FILES" | while read file; do
    base_name=$(basename "$file")
    lock_file="$LOCK_DIR/${base_name}.lock"

    # 檢查是否有鎖檔案
    if [ -e "$lock_file" ]; then
      echo "\033[0;33m檔案 $file 已被另一個進程處理，跳過。\033[0m"
      continue
    fi

    # 創建鎖檔案
    touch "$lock_file"

    # 顯示通知：發現檔案並開始轉換
    notify "發現檔案" "開始轉換: $base_name"

    # 轉換檔案為 PDF
    echo "正準備開始轉換\033[0;32m$file\033[0m"
    "$LIBREOFFICE" --headless --convert-to pdf --outdir "$PDF_FOLDER" "$file"

    # 移動原始檔案到 converted 目錄
    mv "$file" "$CONVERTED_FOLDER/"
    echo "\033[0;32m轉換完成\033[0m"
    notify "$base_name" "轉換完成"

    # 刪除鎖檔案
    rm -f "$lock_file"
  done
fi
