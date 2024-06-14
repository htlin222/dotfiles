#!/bin/bash
# title: fswatch_and_convert
# date created: "2023-06-16"

folder_paths=(
    "/Users/mac/Documents/10_PPTX檔/",
    "/Users/mac/Documents/10_DOC檔/",
    "/Users/mac/Documents/10_DOCX檔/"
)

WATCH_FOLDER="/Users/mac/Documents/10_PPTX檔/"
ARCHIVE_FOLDER="$WATCH_FOLDER/archived"
CONVERT_COMMAND="/Applications/LibreOffice.app/Contents/MacOS/soffice --headless --convert-to pdf"

# Create the archive folder if it doesn't exist
mkdir -p "$ARCHIVE_FOLDER"

# Function to convert file to PDF and move it to the watch folder
convert_to_pdf() {
    file="$1"
    filename=$(basename "$file")
    extension="${filename##*.}"
    filename_without_ext="${filename%.*}"
    pdf_filename="$WATCH_FOLDER/$filename_without_ext.pdf"
    archive_path="$ARCHIVE_FOLDER/$filename"

    # Convert file to PDF
    $CONVERT_COMMAND "$file" --outdir "$WATCH_FOLDER"

    # Move the original file to the archive folder
    mv "$file" "$archive_path"

    # Rename the converted PDF file
    mv "$pdf_filename" "$archive_path.pdf"
}

# Start monitoring the folders and trigger the conversion function
fswatch -o "${folder_paths[@]}" | while read -r event; do
    file=$(echo "$event" | awk '{print $1}')

    # Check if the file extension is pptx, ppt, doc, or docx
    if [[ "$file" =~ \.(pptx|ppt|doc|docx)$ ]]; then
        convert_to_pdf "$file"
    fi
done
