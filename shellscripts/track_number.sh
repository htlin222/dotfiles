#!/bin/bash
# Author: Hsieh-Ting Lin
# Title: "track_number"
# Date: "2023-12-29"
# Version: 1.0.0
# Notes: 幫這個資料夾內的mp3 的 metadata 編號

# Counter for track number
track_number=1
# Iterate through all mp3 files in the current directory
for file in *.mp3; do
	# Check if the file is a regular file
	if [ -f "$file" ]; then
		# Use eyeD3 to set the track number
		eyeD3 --track "$track_number" "$file"

		# Increment track number
		((track_number++))
	fi
done

echo "Track numbers assigned successfully."
