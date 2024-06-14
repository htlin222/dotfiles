#!/bin/bash
# Description:
#   This script processes files in specified directories by replacing the string 'texttospeech' with 'tts' and extracting text after the '#' character to a new file.
#   It then calls another script to perform text-to-speech conversion on the extracted text.
# Usage: ./process_files.sh
# Parameters:
# Date: "2023-12-20"
# Examples:
#   ./add_tts.sh
#
base_dest_dir="$HOME/Desktop/process.nosync"
IFS=$'\n'

# 定義一個包含多個源目錄的數組
source_dirs=("$HOME/Dropbox/Medical/" "$HOME/Dropbox/inbox/")

# 循環遍歷每個源目錄
for src_dir in "${source_dirs[@]}"; do
	files_with_tts=$(rg -l -- 'texttospeech' "$src_dir")
	# 遍歷找到的文件列表
	for file in $files_with_tts; do
		sed -i '' 's/texttospeech/tts/g' "$file"
		filename=$(basename -- "$file")
		filename_no_ext="${filename%.*}"
		filename_no_ext=${filename_no_ext// /_}
		awk '/^# / {p=1} p' "$file" >"$base_dest_dir/$filename_no_ext.txt"
		echo "✅ 修改並提取到 $base_dest_dir/$filename_no_ext.txt"
		sh /Users/htlin/.dotfiles/shellscripts/batch_tts.sh
	done
done
unset IFS
