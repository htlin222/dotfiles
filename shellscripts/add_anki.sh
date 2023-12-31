#!/bin/bash
# Author: Hsieh-Ting Lin
# title: "add_anki"
# date: "2023-12-20"

# Note: Make sure Anki is running in the background

if ! ps aux | grep "/Applications/Anki.app/Contents/Frameworks" | grep -v grep >/dev/null; then
	echo "Anki is not running. Starting Anki..."
	# 開啟 Anki
	open -g /Applications/Anki.app
	# 等待 3 秒，讓 Anki 有時間啟動
	sleep 3

	# 等待 Anki 啟動
	while ! ps aux | grep "/Applications/Anki.app/Contents/Frameworks" | grep -v grep >/dev/null; do
		echo "Waiting for Anki to start..."
		sleep 1
	done
fi

echo "Anki is running. Continuing with the script..."
# Define source directory where medical-related files are located.
source_dir="$HOME/Dropbox/Medical/"
# Define the base destination directory for Anki cards.
base_dest_dir="$HOME/Dropbox/ankicards"
# Get the current date in year-month-day format.
today=$(date +%y-%m-%d)
# Create a destination directory for today's date.
dest_dir="$base_dest_dir/$today"
# Ensure the destination directory exists, create if it doesn't.
mkdir -p "$dest_dir"
open -g /Applications/Anki.app
# Set the Internal Field Separator to newline for handling filenames with spaces.
IFS=$'\n'
# Find all files in the source directory tagged with 'ankinew'.
files_with_ankinew=$(rg -l -- 'ankinew' "$source_dir")
# Iterate through the list of files found.
for file in $files_with_ankinew; do
	# Replace 'ankinew' with 'ankicard' in each file.
	sed -i '' 's/ankinew/ankicard/g' "$file"
	# Extract the filename from the full path.
	filename=$(basename -- "$file")
	# Remove the file extension from the filename.
	filename_no_ext="${filename%.*}"
	# Extract content starting from the first markdown header and save to a new file.
	awk '/^# / {p=1} p' "$file" >"$dest_dir/$filename_no_ext.md"
	# Inform the user of the modification and extraction.
	echo "✅ Modified and extracted to $dest_dir/$filename_no_ext.md"
	# Run a Python script to add the markdown file to Anki without frontmatter.
	python $HOME/pyscripts/add_md_to_anki_no_frontmatter.py "$dest_dir/$filename_no_ext.md"
done
# Reset the Internal Field Separator to its default value.
unset IFS
