#!/bin/bash
# 1. Install pandoc from http://johnmacfarlane.net/pandoc/
# 2. Copy this script into the directory containing the .md files
# 3. Ensure that the script has execute permissions
# 4. Run the script
#
# By default this will keep the original .md file

FILES=*.md
for f in $FILES
do
  # extension="${f##*.}"
  filename="${f%.*}"
  echo "Converting $f to $filename.md"
  `pandoc --citeproc --bibliography="$HOME/Zotero/zotero_main.bib" -s -t gfm --csl="$HOME/Zotero/styles/american-medical-association.csl" "$f" -o "$filename.md"`
done
