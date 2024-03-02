#!/bin/bash
# Author: Hsieh-Ting Lin
# Title: "pomodoro"
# Date: "2024-03-03"
# Version: 1.0.0
# description: "pomodoro, need pipx install termdown"
# 默認參數設置
focus_min=${1:-25}
break_min=${2:-5}
long_break_min=${3:-15}
cycle_for_long_break=${4:-4}

# 初始化週期計數器
cycle_count=0
tomato=""

while true; do
	((cycle_count++)) # 增加週期計數
	tomato+="🍅"
	echo -e "\n\033[32m📚第${cycle_count}專注時間：${focus_min} 分鐘。開始！ 現在時間：$(date '+%Y-%m-%d %H:%M:%S')\033[0m"
	osascript -e "display notification \"$tomato\" with title \"番茄鐘開始於$(date '+%H:%M:%S')\""
	termdown -T "Focus📚" "$focus_min"m

	if ((cycle_count % cycle_for_long_break == 0)); then
		echo -e "\033[34m長休息時間：${long_break_min} 分鐘。\033[0m"
		osascript -e "display notification \"記得起來走走🚶\" with title \"🦦長休息到了，現在$(date '+%H:%M:%S')\""
		termdown -T "Break🛌" "$long_break_min"m
		cycle_count=0
		tomato=""
	else
		echo -e "\033[34m🕹️休息時間：$break_min 分鐘。在3秒後開始\033[0m"
		osascript -e "display notification \"記得起來喝水🚰\" with title \"短休息到了$(date '+%H:%M:%S')\""
		termdown -T "Break🛌" "$break_min"m
	fi

	echo "休息時間結束。準備回到工作吧！💪"
	osascript -e 'display notification with title "休息結束" subtitle "💪"'
	read -t 5 -p "按'q'退出，5秒內無操作將自動繼續：" user_input
	if [ "$?" -eq 0 ] && [ "$user_input" = "q" ]; then
		echo "🍅番茄鐘結束，後會有期。🤗"
		exit 0
	else
		echo "5秒無輸入，自動繼續..."
	fi
done
