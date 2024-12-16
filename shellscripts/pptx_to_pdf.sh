#!/bin/bash
# Author: Hsieh-Ting Lin
# title: "pptx_to_pdf"
# date created: "2023-11-16"

# 設定目錄
PDF_FOLDER="$HOME/Documents/10_PDF檔" # PDF 存放目錄
SOURCE_FOLDER="${PDF_FOLDER}"        # 使用 {} 進行變數替換
CONVERTED_FOLDER="${PDF_FOLDER}/converted"
CCO_SLIDES_DIR="${PDF_FOLDER}/CCO_slides"
LIBREOFFICE="/Applications/LibreOffice.app/Contents/MacOS/soffice"

# 檢查並創建 converted 和 PDF 存放目錄
mkdir -p "$PDF_FOLDER"
mkdir -p "$CONVERTED_FOLDER"

# 尋找當前目錄中的 .ppt 和 .pptx 檔案
FILES=$(find "$SOURCE_FOLDER" -maxdepth 1 -type f \( -name "*.ppt" -o -name "*.pptx" \))

if [ -z "$FILES" ]; then
  # 如果沒有找到檔案，以綠色文字輸出訊息
  echo "\033[0;32m在[10_PDF]裡沒有找到任何 .ppt 或 .pptx 檔案。\033[0m"
else
  # 如果找到檔案，則進行轉換
  echo "$FILES" | while read file; do
    # 轉換檔案為 PDF
    "$LIBREOFFICE" --headless --convert-to pdf --outdir "$PDF_FOLDER" "$file"
    echo "正準備開始轉換\033[0;32m$file\033[0m"
    # 轉換後移動原始檔案到 converted 目錄
    #
    # 獲取檔案基本名稱（不含路徑）
    base_name=$(basename "$file")

    # 如果檔案名稱以 "CCO" 開頭，則移動 PDF 到 CCO_slides 目錄
    # if [[ $base_name == CCO* ]]; then
    # 	# 構建 PDF 檔案名稱
    # 	pdf_file="${PDF_FOLDER}/${base_name%.*}.pdf"
    # 	mv "$pdf_file" "$CCO_SLIDES_DIR/"
    # fi
    mv "$file" "$CONVERTED_FOLDER/"
    echo "\033[0;32m轉換完成\033[0m"
    osascript -e 'display notification "轉換完成" with title "通知"'
  done
fi
