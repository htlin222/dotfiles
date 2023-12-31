#!/bin/bash
# title: rename_DC_Zlib
# date created: "2023-06-14"

# Specify the directory path
directory="./"

# Change to the specified directory
cd "$directory" || exit 1

# Loop through all files in the directory
for file in *; do
    # Check if the file name contains " (Z-Library)"
    if [[ $file == *" (Z-Library)"* ]]; then
        # Remove the " (Z-Library)" substring from the file name
        new_name="${file// (Z-Library)/}"

        # Rename the file
        mv "$file" "$new_name"

        # Print the renamed file name
        echo "Renamed: $file -> $new_name"
    fi
done
exit 0


