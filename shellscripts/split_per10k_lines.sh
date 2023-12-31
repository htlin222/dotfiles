#!/bin/bash
# Author: Hsieh-Ting Lin
# title: "split_per10k_lines"
# date created: "2023-12-19"
#!/bin/bash

if [ $# -ne 1 ]; then
	echo "Usage: $0 <input_file>"
	exit 1
fi

input_file="$1"
lines_per_file=10000
output_prefix="file"

# 计算输入文件的总行数
total_lines=$(wc -l <"$input_file")

# 初始化文件计数器
file_counter=1

# 初始化行计数器
line_counter=0

# 在循环之前创建一个临时文件夹
temp_dir=$(mktemp -d)

# 逐行读取输入文件
while IFS= read -r line; do
	# 将行添加到临时文件
	echo "$line" >>"$temp_dir/temp_file"

	# 增加行计数器
	((line_counter++))

	# 如果达到每个文件的行数限制
	if [ "$line_counter" -eq "$lines_per_file" ]; then
		# 将临时文件重命名为输出文件
		mv "$temp_dir/temp_file" "$output_prefix.$(printf "%03d" "$file_counter").txt"

		# 重置行计数器
		line_counter=0

		# 增加文件计数器
		((file_counter++))
	fi
done <"$input_file"

# 如果还有剩余的行没有处理
if [ -n "$temp_file" ]; then
	# 将剩余的临时文件重命名为输出文件
	mv "$temp_dir/temp_file" "$output_prefix.$(printf "%03d" "$file_counter").txt"
fi

# 删除临时目录
rm -rf "$temp_dir"
