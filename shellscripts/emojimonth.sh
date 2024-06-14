#!/bin/bash
# Author: Hsieh-Ting Lin
# title: "emojimonth"
# date created: "2023-12-15"

# 接受用戶輸入的月份數
input_month=$1

# 確保用戶輸入了參數
if [ -z "$input_month" ]; then
	echo "請提供一個月份數作為參數。"
	exit 1
fi

# 確保輸入的月份數是有效的
if [[ ! $input_month =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
	echo "請提供有效的月份數。"
	exit 1
fi

# 轉換月份數為表情符號
emojis=""

# 處理整數部分
integer_part=$(echo "$input_month" | cut -d '.' -f 1)
for ((i = 0; i < integer_part; i++)); do
	emojis+="🌕"
done

# 處理小數部分
decimal_part=$(echo "$input_month" | cut -d '.' -f 2)
if [ ! -z "$decimal_part" ]; then
	first_digit=${decimal_part:0:1}
	case $first_digit in
	1 | 2 | 3)
		emojis+="🌘"
		;;
	4 | 5 | 6)
		emojis+="🌗"
		;;
	7 | 8 | 9)
		emojis+="🌖"
		;;
	esac
fi

# 輸出表情
echo "$emojis"
