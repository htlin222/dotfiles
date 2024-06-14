#/bin/bash
# title: convert_pdf
# date created: "2023-06-12"
#
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Pull Requests page
# @raycast.mode silent
#
# Optional parameters:
# @raycast.packageName Convert PDF
# @raycast.icon 🔮
# @raycast.iconDark 🔮
#
# List of folders to process
folder_paths=(
    "/Users/mac/Documents/10_PPTX檔"
    "/Users/mac/Documents/10_DOC檔"
    "/Users/mac/Documents/10_DOCX檔"
)


for folder_path in "${folder_paths[@]}"; do
    echo "Processing folder: $folder_path"

    converted_dir="$folder_path/converted"

    # Create the 'converted' directory if it doesn't exist
    if [ ! -d "$converted_dir" ]; then
        mkdir "$converted_dir"
        echo "Created directory: $converted_dir"
    fi

    for file in "$folder_path"/*.pptx "$folder_path"/*.ppt; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            extension="${filename##*.}"

            if [ "$extension" == "pptx" ] || [ "$extension" == "ppt" ] || [ "$extension" == "doc" ] || [ "$extension" == "docx" ]; then
                echo "Converting $filename"
                command /Applications/LibreOffice.app/Contents/MacOS/soffice --headless --convert-to pdf "$file" --outdir "$folder_paths"
                echo "$filename converted"

                # Move the original file to the 'converted' directory
                mv "$file" "$converted_dir/"
                echo "Moved $filename to $converted_dir/"
            fi
        fi
    done

    echo "Folder: $folder_path processing complete"
done
