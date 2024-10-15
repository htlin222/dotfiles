#!/bin/bash
# title: to_pdf
# date created: "2023-09-26"
#
#
# Path to the CSS file
# Define the path to the CSS file
FILE_PATH="$HOME/Dropbox/slides/contents/themes/my-theme.css"

# Automatically create the new file name based on FILE_PATH
NEW_FILE="${FILE_PATH%.*}-no-animation.css"

# Remove all lines after the specified comment and save to a new file
sed '/\/\* animation \*\//q' "$FILE_PATH" >"$NEW_FILE"

# Run Marp with the new CSS file
marp --theme "$NEW_FILE" "$1" --engine "$HOME/Dropbox/slides/src/engine.js" --html -o "$HOME/Dropbox/tmp/${1%.*}.pdf" --allow-local-files --pdf-outlines --pdf-outlines.pages=false --pdf-notes

# Open the output directory
open "$HOME/Dropbox/tmp/"

# Exit the script
exit 0
