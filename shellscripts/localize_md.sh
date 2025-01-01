#!/bin/bash
# title: "localize_md"
# author: Hsieh-Ting Lin
# date: "2024-12-28"
# version: 1.0.0
# description:
# --END-- #
#!/bin/bash

# Check if input file is provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 input.md"
  exit 1
fi

INPUT_FILE="$1"
INPUT_NAME="${INPUT_FILE%.md}"
ASSETS_DIR="./${INPUT_NAME}_assets"
OUTPUT_FILE="${INPUT_NAME}_local.md"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
  echo "Error: File $INPUT_FILE not found"
  exit 1
fi

# Create assets directory if it doesn't exist
mkdir -p "$ASSETS_DIR"

# Clear output file if it exists
>"$OUTPUT_FILE"

# Process the markdown file using grep to find image patterns, then process each line
grep -n "!\[.*\](https://" "$INPUT_FILE" | while IFS=: read -r line_num line; do
  # Extract URL using grep and cut
  img_url=$(echo "$line" | grep -o "(https://[^)]*)" | sed 's/^(//' | sed 's/)$//')

  if [ -n "$img_url" ]; then
    # Generate filename from URL
    filename=$(basename "$img_url" | sed 's/[^a-zA-Z0-9._-]/_/g')
    local_path="${ASSETS_DIR}/${filename}"

    # Download the image if it doesn't exist
    if [ ! -f "$local_path" ]; then
      echo "Downloading $img_url to $local_path"
      if ! curl -sSL "$img_url" -o "$local_path"; then
        echo "Warning: Failed to download $img_url"
      fi
    fi

    # Replace the remote URL with local path in the line
    sed "s|$img_url|./${INPUT_NAME}_assets/$filename|" <<<"$line" >>"$OUTPUT_FILE"
  fi
done

# Copy lines without images
grep -v "!\[.*\](https://" "$INPUT_FILE" >>"$OUTPUT_FILE"

# Sort the output file based on original line numbers
sort -n -o "$OUTPUT_FILE" "$OUTPUT_FILE"

echo "Processing complete. Images have been downloaded to $ASSETS_DIR"
echo "Local version of markdown file has been created: $OUTPUT_FILE"
