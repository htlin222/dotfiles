#!/bin/bash
# title: "apy_batch_add_to_anki"
# author: Hsieh-Ting Lin
# date: "2024-08-23"
# version: 1.0.0
# description:
# --END-- #
set -ue
set -o pipefail
trap "echo 'END'" EXIT

LOGFILE="/tmp/anki_note_import.log"
DONE_DIR="/tmp/done_anki"

# 清空日志文件
>"$LOGFILE"

# 檢查 apy 命令是否存在於 PATH 中
if ! command -v apy &>/dev/null; then
  echo "Error: 'apy' command not found in PATH" | tee -a "$LOGFILE"
  exit 1
fi

# 創建 done_anki 目錄如果不存在
if [ ! -d "$DONE_DIR" ]; then
  mkdir -p "$DONE_DIR"
fi

for markdownfile in /tmp/anki_note/*.md; do
  if [ -f "$markdownfile" ]; then
    echo "Processing $markdownfile" | tee -a "$LOGFILE"
    if apy add-from-file "$markdownfile"; then
      echo "Successfully added $markdownfile" | tee -a "$LOGFILE"
      mv "$markdownfile" "$DONE_DIR/"
      echo "Moved $markdownfile to $DONE_DIR/" | tee -a "$LOGFILE"
    else
      echo "Failed to add $markdownfile" | tee -a "$LOGFILE"
    fi
  else
    echo "No .md files found in /tmp/anki_note" | tee -a "$LOGFILE"
  fi
done

apy sync
