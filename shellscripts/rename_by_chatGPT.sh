#!/bin/bash
# Author: Hsieh-Ting Lin
# Title: "rename"
# Date: "2024-02-06"
# Version: 1.0.0
# desc: rename by ChatGP
#
# 同目錄下新增一個 .env 檔將 OPENAI_API_KEY=sk-xxxx 放在裡面
# 將.env檔案中的變量加載到當前shell環境中
# set -a # 自動導出變量
# source .env
# set +a # 關閉自動導出
# 不要直接把api存在這個程式碼中

# API_ENDPOINT="https://api.openai.com/v1/chat/completions"

pdf_folder="$HOME/Downloads/10_PDF檔/"
output_dir="$HOME/Documents/10_PDF檔/"
current_date=$(date +'%Y-%m-%d')

if [ ! -d "$output_dir" ]; then
	mkdir -p "$output_dir"
fi

json_escape() {
	local string=$1
	# 使用 sed 進行轉義特殊字元
	echo "$string" | sed 's/\\/\\\\/g; s/"/\\"/g; s/[/]/\\[/g; s/]/\\]/g; s/{/\\{/g; s/}/\\}/g; s/#/\\#/g; s/!/\\!/g; s/\t/\\t/g; s/\n/\\n/g; s/\r/\\r/g'
}

for pdf_file in "$pdf_folder"/*.pdf; do
	if [ -f "$pdf_file" ]; then
		first_page_text=$(pdftotext "$pdf_file" - | tr -d '[:punct:]' | tr '\n' ' ' | tr -s '[:space:]' ' ' | tr -d '\001' | cut -d ' ' -f 1-50)
		first_page_text=$(json_escape "$first_page_text")
		# echo "$first_page_text" for Debug

		if [ ${#first_page_text} -gt 10 ]; then

			REQUEST_DATA='{
      "model": "gpt-3.5-turbo",
      "messages": [
          {
            "role": "system",
            "content": "read the following text, return a title for me. The title should less than 40 char, only English, Chinese, or Numbers. No special character. No explaination: "
          },
          {
            "role": "user",
            "content": "'"$first_page_text"'"
          }
        ]
}'
			# echo "$REQUEST_DATA" >"test.json" # For debug

			# content=$(curl -s -X POST "$API_ENDPOINT" \
			# 	-H "Content-Type: application/json" \
			# 	-H "Authorization: Bearer $OPENAI_API_KEY" \
			# 	-d "$REQUEST_DATA" | jq -r '.choices[0].message.content')

			content=$(curl -s "$AZURE_OPENAI_ENDPOINT"/openai/deployments/PHEgpt/chat/completions?api-version=2023-03-15-preview \
				-H "Content-Type: application/json" \
				-H "api-key: $AZURE_OPENAI_KEY" \
				-d "$REQUEST_DATA" | jq -r '.choices[0].message.content')

			GROUPING='{
      "model": "gpt-3.5-turbo",
      "messages": [
          {
            "role": "system",
            "content": "Read the following text, and return only one of: guideline, journal, slides, book, or other;  without explain"
          },
          {
            "role": "user",
            "content": "'"$first_page_text"'"
          }
        ]
}'
			# echo "$REQUEST_DATA" >"test.json" # For debug
			group=$(curl -s "$AZURE_OPENAI_ENDPOINT"/openai/deployments/PHEgpt/chat/completions?api-version=2023-03-15-preview \
				-H "Content-Type: application/json" \
				-H "api-key: $AZURE_OPENAI_KEY" \
				-d "$GROUPING" | jq -r '.choices[0].message.content' | tr -d '[:punct:]' | tr '[:upper:]' '[:lower:]')

			# group=$(curl -s -X POST "$API_ENDPOINT" \
			# 	-H "Content-Type: application/json" \
			# 	-H "Authorization: Bearer $OPENAI_API_KEY" \
			# 	-d "$GROUPING" | jq -r '.choices[0].message.content')
			# curl -s -X POST "$API_ENDPOINT" \
			# 	-H "Content-Type: application/json" \
			# 	-H "Authorization: Bearer $OPENAI_API_KEY" \
			# 	-d "$REQUEST_DATA"

			if [ "$content" = "null" ]; then
				echo "FAIL, use the original name"
				content="${pdf_file%.*}"
			fi
			if [ "$group" = "null" ]; then
				echo "FAIL, use the original name"
				group="NA"
			fi
			file_name=$(echo "$content" | tr '-' ' ' | tr -d '[:punct:]' | tr -s '[:space:]' '_' | sed 's/_$//')
			file_name="$current_date-[$group]-$file_name"
			echo "✔ Final Filename: $file_name"
			mv "$pdf_file" "$output_dir/$file_name.pdf"
		else
			echo "Cannot Read the content from $pdf_file"
		fi

		# 重新命名並移動
	fi
done
