#!/bin/bash
# Author: Hsieh-Ting Lin
# Title: "do_not_block_app"
# Date: "2024-02-18"
# Version: 1.0.0
# Notes:

find "/Applications" -type d -maxdepth 1 -name "*.app" -amin -20 | while read app; do
	echo "👌Removing quarantine from: $app"
	sudo xattr -r -d com.apple.quarantine "$app"
done
echo "run at $(date)"
