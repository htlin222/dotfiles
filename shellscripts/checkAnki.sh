#!/bin/bash
# title: checkAnki
# date: "2023-12-20"
# 這個 bash 腳本是用來檢查 Anki 應用程序是否正在運行，如果沒有則啟動它
# 首先檢查是否有一個進程包含 "/Applications/Anki.app/Contents/Frameworks"，
# 這個路徑是 Anki 應用程序的典型位置。`grep -v grep` 是用來排除搜尋 `grep` 命令本身的結果。
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

if ! is_mac; then
	echo "This script is macOS-only." >&2
	exit 1
fi

if ! ps aux | grep "/Applications/Anki.app/Contents/Frameworks" | grep -v grep >/dev/null; then
	# 如果 Anki 沒有運行，顯示一條消息並啟動 Anki
	echo "Anki is not running. Starting Anki..."

	# 使用 `open -g` 命令啟動 Anki，-g 選項意味著不將 Anki 帶到前台（不激活窗口）
	open_cmd -g /Applications/Anki.app

	# 等待 3 秒鐘，給 Anki 一些時間來啟動
	sleep 3

	# 在一個循環中等待 Anki 啟動。這是通過檢查 Anki 進程是否存在來實現的
	while ! ps aux | grep "/Applications/Anki.app/Contents/Frameworks" | grep -v grep >/dev/null; do
		# 如果 Anki 還沒有啟動，則每隔 1 秒顯示一條消息並檢查一次
		echo "Waiting for Anki to start..."
		sleep 1
	done
fi

# 當確定 Anki 正在運行時，顯示一條消息並繼續執行腳本的其餘部分
echo "Anki is running. Continuing with the script..."
