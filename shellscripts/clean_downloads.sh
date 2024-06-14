#!/bin/bash
# title: clean_downloads
# date created: "2023-02-12"


downloads_dir=~/Downloads

for file in "$downloads_dir"/*; do
  if [ -d "$file" ]; then
    if [[ ! "$file" =~ ^[0-9][0-9][0-9][0-9]-.* ]]; then
      if [[ "$file" != sorted_* ]]; then
        dir_date=$(find "$file" -printf '%TY%Tm\n')
        year_month=${dir_date:0:6}
        sorted_dir="$downloads_dir/$year_month"
        if [ ! -d "$sorted_dir" ]; then
          mkdir "$sorted_dir"
        fi
        mv "$file" "$sorted_dir"
      fi
    fi
  elif [ -f "$file" ]; then
    extension="${file##*.}"
    sorted_dir="$downloads_dir/sorted_$extension"
    if [ ! -d "$sorted_dir" ]; then
      mkdir "$sorted_dir"
    fi
    mv "$file" "$sorted_dir"
  fi
done
