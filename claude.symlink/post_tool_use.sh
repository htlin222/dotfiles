#!/bin/bash

# Read JSON from stdin
json_input=$(cat)

# Extract file path and content using jq
file_path=$(echo "$json_input" | jq -r '.tool_input.file_path')
content=$(echo "$json_input" | jq -r '.tool_input.content')

# Get file extension
extension="${file_path##*.}"

# Define supported extensions for prettier
prettier_extensions=("html" "css" "js" "jsx" "tsx" "ts" "json" "md" "mdx" "scss" "less" "vue" "yaml" "yml")

# Check if extension is in the supported list
should_format=false
for ext in "${prettier_extensions[@]}"; do
  if [[ "$extension" == "$ext" ]]; then
    should_format=true
    break
  fi
done

# Format with prettier if supported
if $should_format; then
  # Write content to temp file
  temp_file=$(mktemp)
  echo "$content" >"$temp_file"

  # Run prettier
  if prettier --write "$temp_file" 2>/dev/null; then
    # Read formatted content back
    formatted_content=$(cat "$temp_file")

    # Update the JSON with formatted content
    updated_json=$(echo "$json_input" | jq --arg content "$formatted_content" '.tool_input.content = $content')

    # Output the updated JSON
    echo "$updated_json"

    # Log success (optional)
    echo "✨ Formatted $file_path with Prettier" >&2
  else
    # If prettier fails, output original JSON
    echo "$json_input"
    echo "⚠️  Prettier formatting failed for $file_path" >&2
  fi

  # Clean up temp file
  rm -f "$temp_file"
else
  # Not a supported file type, pass through unchanged
  echo "$json_input"
fi
