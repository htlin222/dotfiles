#!/bin/bash
# Author: Hsieh-Ting Lin
# title: "gen_medium_og"
# date created: "2023-12-17"

if [ $# -eq 0 ]; then
	echo "Usage: $0 <slide_name>"
	exit 1
fi

slide_name="$1"
slide_path="$HOME/Dropbox/slides"
tmp_path="$HOME/Dropbox/tmp"

cp "$slide_path/cover.md" "$tmp_path/$slide_name.md"
printf '\n\n# %s\n\n' "$slide_name" >"$tmp_path/tmpfile.md"
sed -i '' '9 {
  r '"$tmp_path/tmpfile.md"'
  N
}' "$tmp_path/$slide_name.md"
marp --theme-set "$slide_path/themes" --html --images png "$tmp_path/$slide_name.md" -o "$tmp_path/$slide_name.png"
rm "$tmp_path/tmpfile.md"
echo "Slide created: $tmp_path/$slide_name.png"
# pbcopy <"$tmp_path/$slide_name.001.png"
open "$tmp_path"
