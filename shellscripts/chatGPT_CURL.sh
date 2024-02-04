#!/bin/bash
# Author: Hsieh-Ting Lin
# Title: "chatGPT_CURL"
# Date: "2024-02-04"
# Version: 1.0.0
# Notes:

# Parse command-line arguments
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

# API endpoint for chat completions
API_ENDPOINT="https://api.openai.com/v1/chat/completions"

# JSON data for the API request
REQUEST_DATA='{
  "model": "gpt-3.5-turbo",
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

# Make the API call and store the response in a temporary file named 'tmp.json'

content=$(curl -s -X POST "$API_ENDPOINT" \
	-H "Content-Type: application/json" \
	-H "Authorization: Bearer $OPENAI_API_KEY" \
	-d "$REQUEST_DATA" | jq -r '.choices[0].message.content')

# Print the extracted content
echo "$content" | glow
