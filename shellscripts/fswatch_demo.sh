#!/bin/bash
# title: test
# date created: "2023-06-13"

folder_paths=(
    "/Users/mac/Documents/10_PPTX檔/"
    "/Users/mac/Documents/10_DOC檔/"
    "/Users/mac/Documents/10_DOCX檔/"
)

for WATCH_FOLDER in folder_paths
  fswatch -r "$WATCH_FOLDER" | while read -r FILE
do
  echo "Hello"
done


