#!/bin/bash
# title: "clean_app"
# author: Hsieh-Ting Lin
# date: "2025-03-18"
# version: 1.0.0
# description:
# --END-- #
set -ue
set -o pipefail
trap "echo 'END'" EXIT

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./shellscripts/lib.sh
source "$SCRIPT_DIR/lib.sh"

if ! is_mac || ! command -v osascript >/dev/null 2>&1; then
  echo "This script is macOS-only (requires osascript)." >&2
  exit 1
fi

# 設定閒置時間 (秒) ，這裡設定為 1800 秒 (30 分鐘)
IDLE_TIME=18

# 設定應用白名單 (這些應用不會被關閉)
WHITELIST=("Finder" "wezterm-gui" "Line" "ChatGPT" "1Password")

# 取得前景應用名稱
FOREGROUND_APP=$(osascript -e 'tell application "System Events" to get name of first process whose frontmost is true')

# 列出所有運行的 GUI 應用
for app in $(osascript -e 'tell application "System Events" to get name of (every process whose background only is false)'); do
  # 跳過目前前景運行的應用
  if [ "$app" == "$FOREGROUND_APP" ]; then
    continue
  fi

  # 檢查是否在白名單內
  for whitelisted in "${WHITELIST[@]}"; do
    if [ "$app" == "$whitelisted" ]; then
      continue 2 # 跳過這個應用，進入下一個迴圈
    fi
  done
  # 取得應用的 PID
  PID=$(pgrep -f "$app")

  # 確保找到 PID
  if [ -z "$PID" ]; then
    continue
  fi

  # 取得應用的運行時間 (elapsed time)
  START_TIME=$(ps -o lstart= -p "$PID" | head -n 1)

  # 確保取得時間
  if [ -z "$START_TIME" ]; then
    continue
  fi

  # 計算運行時間（macOS 與 Linux 通用）
  if [[ "$OSTYPE" == "darwin"* ]]; then
    ELAPSED=$(($(date +%s) - $(date -jf "%a %b %d %T %Y" "$START_TIME" +%s)))
  else
    ELAPSED=$(($(date +%s) - $(date -d "$START_TIME" +%s)))
  fi

  echo $ELAPSED $START_TIME

  # 確保 ELAPSED 為數值
  if [[ -n "$ELAPSED" && "$ELAPSED" -gt "$IDLE_TIME" ]]; then
    echo "Closing $app (Elapsed: $ELAPSED sec, Idle limit: $IDLE_TIME sec)"
    osascript -e "tell application \"$app\" to quit"
  fi
done
