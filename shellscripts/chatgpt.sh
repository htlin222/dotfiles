#!/bin/bash
# title: openai
# date created: "2023-08-20"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./shellscripts/lib.sh
source "$SCRIPT_DIR/lib.sh"

text=$(pbpaste_cmd | tr -d '\n')
if [ -n "$text" ]; then
    title="即將繁中解釋的文字如下"
    notify "$title" "$text"
    if command -v op >/dev/null 2>&1; then
        OPENAI_API_KEY="$(op read op://Dev/chat_GPT/api\ key)"
    fi
    if [ -z "$OPENAI_API_KEY" ]; then
        echo "OPENAI_API_KEY not set" >&2
        exit 1
    fi
    response=$( curl https://api.openai.com/v1/chat/completions \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $OPENAI_API_KEY" \
            -d "{
      \"model\": \"gpt-3.5-turbo\",
      \"messages\": [{\"role\": \"user\", \"content\": \"請用繁體中文解釋以下文字: $text\"}],
      \"temperature\": 0.7
    }")

    content=$(echo "$response" | jq -r '.choices[0].message.content')
    # echo "$content" > response.txt
    title="完成"
    notify "$title" "$content"
    echo "$content" | pbcopy_cmd
    echo "done"
else
    echo "The clipboard is empty."
    title="剪貼版裡面沒有東西"
    text="你確定你有文字要處理嗎？"
    notify "$title" "$text"
fi
