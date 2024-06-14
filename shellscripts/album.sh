#!/bin/bash
# title: batch
# date created: "2023-08-03"
# Loop through all files in the current directory
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# CONSTANT
cover_image="cover.jpg"
read -r artist <"artist.txt"
genere="Audio Book"
album=$(cat "album.txt")
# album=$(basename "$(pwd)")
# SHOW HELP
if [[ "$1" == "-h" ]]; then
	echo "Usage: album.sh [OPTIONS]"
	echo
	echo "Options:"
	echo "  -h    Show help message"
	echo "  -f    Specify a file"
	exit 0
fi
# Ensure 'lame' and 'eyeD3' are installed
if ! command -v id3v2 &>/dev/null || ! command -v eyeD3 &>/dev/null; then
	echo "Please install 'id3v2' and 'eyeD3' before running this script."
	exit 1
fi

# Clear Filename
for file in ./*; do
	# Check if the file name contains square brackets with possible spaces
	if [[ $file =~ [[:blank:]]*\[.*\][[:blank:]]* ]]; then
		# Extract the text inside the brackets and replace it with nothing
		new_name=$(echo "$file" | sed -E 's/[[:blank:]]*\[.*\][[:blank:]]*//')
		# Rename the file
		mv "$file" "$new_name"
	fi
done

id3v2 -A "$album" *.mp3
id3v2 -a "$artist" *.mp3
id3v2 -g "$genere" *.mp3
# Get the total number of MP3 files in the current directory
total_files=$(find . -maxdepth 1 -type f -iname "*.mp3" | wc -l)
track_number=1
find . -maxdepth 1 -type f -iname "*.mp3" | sort | while read -r file; do
	id3v2 --track "$track_number/$total_files" "$file"
	# title="${file% $album*}"
	title=$(echo "$file" | sed 's/[^[:print:]]//g')
	title="${title%.mp3}"
	title="${title:2}"
	id3v2 --song "$title" "$file"
	((track_number++))
done
if [ ! -f "$cover_image" ]; then
	echo "Cover image '$cover_image' not found in the current directory."
	exit 1
else
	# Get the current dimensions of the image
	width=$(identify -format "%w" cover.jpg)
	height=$(identify -format "%h" cover.jpg)

	# Check if the image needs resizing
	if [ "$width" -gt 300 ] || [ "$height" -gt 300 ]; then
		# Resize the image to a maximum size of 300x300 and save it as "temp_cover.jpg"
		convert cover.jpg -resize '300x300>' temp_cover.jpg

		# Replace the original "cover.jpg" with the resized image
		mv temp_cover.jpg cover.jpg
	fi
fi
find . -type f -iname "*.mp3" | while read -r file; do
	# Check if a cover image file exists for the current MP3 file
	cover_image="./cover.jpg"
	[ ! -f "$cover_image" ] && cover_image="./cover.png"

	# Add the cover image to the MP3 file using eyeD3
	eyeD3 --add-image "$cover_image:FRONT_COVER" "$file"

	echo "Added cover image to: $file"
done

# Check if a valid cover image file exists in the current directory (replace 'cover.jpg' with your image file)

# Loop through all audio files in the current directory and set the album cover
# for file in ./*; do
#     if [[ -f "$file" ]]; then
#         sed -i 's/\.\./\./g' "$file"
#     fi
# done

exit 0
