#!/bin/bash
# Author: Hsieh-Ting Lin
# Title: add_snippets
# Date: "2023-12-20"
# Description: This shell script searches for files in a specified directory that contain the string "___", extracts content starting from the first level 1 heading, removes backticks, and saves the content to a corresponding file in a specified destination directory. The script also adds a prefix line to the beginning of the extracted content in the format of ".<SUBDIRECTORY>.<PREFIX>". If no prefix is found, the script uses the filename as the prefix.
# Usage: ./snippet_extractor.sh
# Parameters:
#   $source_dir: The directory to search for files containing the string "___"
#   $dest_dir: The destination directory to save the extracted content
#   $subdirs: An array of subdirectories to create inside the destination directory
# Examples:
#   ./add_snippets.sh

source_dir="$HOME/dropbox/Medical/"

# Destination directory
dest_dir="$HOME/KFSYSCC_Drive/snippets_from_lizard"

# Subdirectories list
subdirs=("ae" "boot" "info" "check" "drug" "edu" "fu" "grade" "hx" "icd" "lab" "note" "oop" "plan" "qry" "report" "score" "trial" "tldr" "util" "ssx" "ddx" "nhi")

# Ensure the destination directory and subdirectories exist
mkdir -p "$dest_dir"
for subdir in "${subdirs[@]}"; do
	mkdir -p "$dest_dir/$subdir"
done

# Use rg to search for "___" in the source directory
IFS=$'\n'
files_with_snippet=$(rg -l -- '___' "$source_dir")

# Iterate through the list of files found
for file in $files_with_snippet; do
	# Determine the appropriate subdirectory
	target_subdir=""
	for subdir in "${subdirs[@]}"; do
		if rg --quiet "\-\s$subdir" "$file"; then
			target_subdir="$subdir"
			break
		fi
	done

	# Get the filename without extension
	filename=$(basename -- "$file")
	filename_no_ext="${filename%.*}"

	# Extract content starting from the first level 1 heading, remove backticks
	content=$(awk '/^# / {p=1} p' "$file" | sed 's/`//g')
	target_subdir_upper=$(echo "$target_subdir" | tr '[:lower:]' '[:upper:]' | sed 's/[_ -]/./g')

	# Search for prefix and add it as a line at the beginning
	prefix_line=$(grep -o 'prefix: "[^"]*"' "$file" | sed 's/prefix: "\(.*\)"/\1/' | tr '[:lower:]' '[:upper:]')
	if [ -n "$prefix_line" ]; then
		prefix_line="${prefix_line//[^A-Z0-9]/}"
		content=".$target_subdir_upper.$prefix_line\n$content"
	else
		filename_no_ext_upper=$(echo "$filename_no_ext" | tr '[:lower:]' '[:upper:]' | sed 's/[_ -]/./g')
		content=".$target_subdir_upper.$filename_no_ext_upper\n$content"
		# content=".$(echo "${filename_no_ext_upper}" | sed 's/_/./g')\n$content"
	fi

	# Save to appropriate subdir or dest_dir if no match
	if [ -z "$target_subdir" ]; then
		echo "$content" >"$dest_dir/$filename_no_ext.txt"
		echo "📝$filename_no_ext.txt"
	else
		echo "$content" >"$dest_dir/$target_subdir/$filename_no_ext.txt"
		echo "📂$target_subdir/📝$filename_no_ext.txt"
	fi
done
unset IFS
