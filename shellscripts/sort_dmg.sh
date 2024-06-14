#!/bin/bash
# title: sort_dmg
# date created: "2023-02-12"

# The source directory
src_dir=~/Downloads

# The destination directory
dest_dir=~/Downloads/安裝檔

# Check for new files every 10 seconds
while true; do
    # Find all .dmg files in the source directory
    for file in $(find $src_dir -name "*.dmg"); do
        # Move the file to the destination directory
        mv $file $dest_dir
    done
    # Wait for 10 seconds before checking again
    sleep 10
done


