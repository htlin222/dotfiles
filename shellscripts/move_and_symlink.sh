#!/bin/bash
# title: move_and_symlink
# date created: "2023-02-12"

# Parse the input argument
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        --folder=*)
        folder="${key#*=}"
        shift
        ;;
        *)
        echo "Unknown option: $key"
        exit 1
        ;;
    esac
done

# Define the source and destination directories
src_dir="$HOME/Library/Application Support/$folder"
dst_dir="$DOTFILES/Application_Support/$folder"

# Check if the folder exists
if [ ! -d "$src_dir" ]; then
    echo "Error: The folder $src_dir does not exist."
    exit 1
fi

# Move the source directory to the destination
mv "$src_dir" "$dst_dir"

# Create a symlink from the source directory to the destination
ln -s "$dst_dir" "$src_dir"

exit 0


