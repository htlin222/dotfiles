#!/bin/bash
# Author: Hsieh-Ting Lin
# Title: "azure_cURL"
# Date: "2024-02-06"
# Version: 1.0.0
# Notes:

while getopts ":i:" opt; do
	case $opt in
	i)
		user_message="$OPTARG"
		;;
	\?)
		echo "Invalid option: -$OPTARG" >&2
		exit 1
		;;
	:)
		echo "Option -$OPTARG requires an argument." >&2
		exit 1
		;;
	esac
done

if [ -z "$user_message" ]; then
	echo "Usage: $0 -i <user_message>"
	exit 1
fi

REQUEST_DATA='{
    "messages": [
    {
      "role": "system",
      "content": "You are a helpful assistant."
    },
    {
      "role": "user",
      "content": "'"$user_message"'"
    }
  ]
}'

content=$(curl -s "$AZURE_OPENAI_ENDPOINT"/openai/deployments/PHEgpt/chat/completions?api-version=2023-03-15-preview \
	-H "Content-Type: application/json" \
	-H "api-key: $AZURE_OPENAI_KEY" \
	-d "$REQUEST_DATA" | jq -r '.choices[0].message.content')

echo "$content" | glow
