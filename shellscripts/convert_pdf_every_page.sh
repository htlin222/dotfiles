#!/bin/bash
# Author: Hsieh-Ting Lin
# Title: "convert_pdf_every_page"
# Date: "2023-12-20"
# Version: 1.0.0
# Notes:
# - `brew install poppler` first for bin/pdftotext

# 檢查命令列參數
if [ $# -ne 1 ]; then
	echo "用法: $0 <PDF檔案路徑>"
	exit 1
fi

# 提取檔案名稱和資料夾名
pdf_file="$1"
base_name="${pdf_file%.pdf}"
output_folder="${base_name}/"

# 建立輸出資料夾
mkdir -p "$output_folder"

# 獲取PDF檔案的總頁數
total_pages=$(pdfinfo "$pdf_file" | grep "Pages" | awk '{print $2}')

echo "total $total_pages page"
# 使用pdftotext將每一頁轉換為文字檔
for ((page_number = 1; page_number <= $total_pages; page_number++)); do
	pdftotext -f $page_number -l $page_number "$pdf_file" "${output_folder}${base_name}.$(printf "%03d" $page_number).txt"
done

echo "轉換完成，共有$total_pages個文字檔保存在 $output_folder 資料夾中。"
