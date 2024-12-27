#!/bin/bash
# title: to_html
# date created: "2023-09-30"
input_file="${1%.*}"
slug=$(awk -F 'slug: ' '/slug: /{print $2}' "$1" | sed 's/"//g')
# 檢查 slug 是否為空
if [ -z "$slug" ]; then
  # 如果 slug 為空，則設定 filename 變數為輸入檔案名（不含副檔名）
  filename=$input_file
else
  # 否則，使用 slug
  filename=$slug
fi
if [ -d "./output/$filename" ]; then
  read -p "The folder already exists. Do you want to overwrite it? (y/n) " answer
  if [ "$answer" != "y" ]; then
    echo "Exiting..."
    exit 1
  fi
fi
mkdir -p "./output/$filename"
# cp -r -P "./src" "./output/$filename/"
# cp "$1" "./output/$filename/backup_$(date '+%Y-%m-%d-%H-%M').md"
# mv "$1" "./$filename/"

marp --theme "$HOME/Dropbox/slides/contents/themes/main.css" "$1" --engine "$HOME/Dropbox/slides/src/engine.js" --bespoke.progress --html -o "$filename/index.html"

exit 0
