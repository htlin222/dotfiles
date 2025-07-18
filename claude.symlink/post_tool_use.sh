#!/bin/bash

# Read JSON from stdin
json_input=$(cat)

# Extract file path and content using jq
file_path=$(echo "$json_input" | jq -r '.tool_input.file_path')
content=$(echo "$json_input" | jq -r '.tool_input.content')

# Get file extension
extension="${file_path##*.}"

# Define formatters as an associative array
declare -A formatters=(
  # Prettier-supported extensions
  ["html"]="prettier"
  ["css"]="prettier"
  ["js"]="prettier"
  ["jsx"]="prettier"
  ["tsx"]="prettier"
  ["ts"]="prettier"
  ["json"]="prettier"
  ["md"]="prettier"
  ["mdx"]="prettier"
  ["scss"]="prettier"
  ["less"]="prettier"
  ["vue"]="prettier"
  ["yaml"]="prettier"
  ["yml"]="prettier"
)

# Function to format content
format_content() {
  local formatter=$1
  local temp_file=$(mktemp)
  echo "$content" >"$temp_file"
  
  case "$formatter" in
    "prettier")
      if prettier --write "$temp_file" 2>/dev/null; then
        cat "$temp_file"
        rm -f "$temp_file"
        return 0
      fi
      ;;
  esac
  
  rm -f "$temp_file"
  return 1
}

# Check if formatter exists for this extension
if [[ -n "${formatters[$extension]}" ]]; then
  formatter="${formatters[$extension]}"
  
  if formatted_content=$(format_content "$formatter"); then
    # Update JSON with formatted content
    echo "$json_input" | jq --arg content "$formatted_content" '.tool_input.content = $content'
    echo "✨ Formatted $file_path with ${formatter^}" >&2
  else
    # Formatter failed, pass through unchanged
    echo "$json_input"
    echo "⚠️  ${formatter^} formatting failed for $file_path" >&2
  fi
else
  # No formatter for this file type, pass through unchanged
  echo "$json_input"
fi
