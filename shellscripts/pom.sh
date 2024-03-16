#!/bin/bash
# Author: Hsieh-Ting Lin
# Title: "pomodoro"
# Date: "2024-03-05"
# Version: 1.0.0
# description: "pomodoro, need pipx install termdown"
# 默認參數設置
focus_min=${1:-25}
break_min=${2:-5}
long_break_min=${3:-15}
cycle_for_long_break=${4:-4}
# Change Your Audio Path Here
focus_audio="$HOME/.dotfiles/config.symlink/media/focus_start.mp3"
long_break_audio="$HOME/.dotfiles/config.symlink/media/long_break.wav"
short_break_audio="$HOME/.dotfiles/config.symlink/media/short_break.wav"

# 初始化週期計數器
cycle_count=0
tomato=""

while true; do
	((cycle_count++)) # 增加週期計數
	tomato+="🍅"
	# Link start
	(ffplay -v 0 -nodisp -autoexit "$focus_audio" &>/dev/null &)
	printf "\n\033[32m📚第%d專注時間：%d 分鐘。開始！ 現在時間：%s\033[0m\n" "$cycle_count" "$focus_min" "$(date '+%Y-%m-%d %H:%M:%S')"
	osascript -e "display notification \"$tomato\" with title \"番茄鐘開始於$(date '+%H:%M:%S')\""
	termdown -T "Focus📚" "$focus_min"m

	if ((cycle_count % cycle_for_long_break == 0)); then
		# Long Break
		printf "\033[34m長休息時間：%d 分鐘。\033[0m\n" "$long_break_min"
		osascript -e "display notification \"記得起來走走🚶\" with title \"🦦長休息到了，現在$(date '+%H:%M:%S')\""
		(ffplay -v 0 -nodisp -autoexit "$long_break_audio" &>/dev/null &)
		termdown -T "Break🛌" "$long_break_min"m
		cycle_count=0
		tomato=""
	else
		# Short Break
		printf "\033[34m🕹️休息時間：%d 分鐘。在3秒後開始\033[0m\n" "$break_min"
		osascript -e "display notification \"記得起來喝水🚰\" with title \"短休息到了$(date '+%H:%M:%S')\""
		(ffplay -v 0 -nodisp -autoexit "$short_break_audio" &>/dev/null &)
		termdown -T "Break🛌" "$break_min"m
	fi

	echo "休息時間結束。準備回到工作吧！💪"
	osascript -e 'display notification with title "休息結束" subtitle "💪"'
	read -t 5 -p "按'q'退出，5秒內無操作將自動繼續：" user_input
	if [ "$?" -eq 0 ] && [ "$user_input" = "q" ]; then
		echo "🍅番茄鐘結束，後會有期。🤗"
		(ffplay -v 0 -nodisp -autoexit "$HOME"/.dotfiles/config.symlink/media/end.wav &>/dev/null &)
		exit 0
	else
		echo "5秒無輸入，自動繼續..."
	fi
done
