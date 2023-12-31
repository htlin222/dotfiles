#!/bin/bash
# title: search_post_tag
# date created: "2023-02-27"


source_folder="$HOME/Documents/Medical"

echo "🔃 search for post"
for filename in "$source_folder"/*.md; do
    # Check if the file is a Markdown file
    if [[ -f "$filename" && "$filename" == *.md ]]; then
        # Read the front matter from the file
        tags=$(awk '/^tags:/{flag=1; next} /^---$/{flag=0} flag' "$filename")
        if [[ "$tags" == *"post"* ]]; then
            # Copy the file to the destination folder
            cp -f "$filename" "$destination_folder"
        fi
    fi
done

exit 0


