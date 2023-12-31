#!/bin/bash
# Author: Hsieh-Ting Lin
# title: "emojibyten"
# date created: "2023-12-15"

# 接受一個整數作為參數
if [ $# -ne 1 ]; then
	echo "Usage: $0 <number>"
	exit 1
fi

# 檢查輸入是否是一個有效的整數
if ! [[ $1 =~ ^[0-9]+$ ]]; then
	echo "Input must be a valid integer."
	exit 1
fi

# 將輸入轉換為進度條的長度
num="$1"

# 檢查輸入是否在0到10範圍內
if [ "$num" -lt 0 ] || [ "$num" -gt 10 ]; then
	echo "Input number must be between 0 and 10."
	exit 1
fi

# 計算百分比
percentage=$((num * 10))

# 生成進度條
progress=""
for ((i = 0; i < 10; i++)); do
	if [ "$i" -lt "$num" ]; then
		progress+="🟩"
	else
		progress+="⬜️"
	fi
done

echo "$progress $percentage%"
#!/bin/bash
