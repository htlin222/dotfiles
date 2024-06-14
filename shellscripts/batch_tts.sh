#!/bin/bash

# Set directories and paths
DIRECTORY="/Users/htlin/Desktop/process.nosync"
PYTHON_ENV="/Users/htlin/.pyenv/versions/my_openai/bin/python"
SCRIPT_PATH="/Users/htlin/Dropbox/scripts/my_openai"
MP3_DESTINATION="$HOME/Library/CloudStorage/GoogleDrive-ppoiu87@gmail.com/我的雲端硬碟/audio/"

# Change to the specified directory
cd "$DIRECTORY" || {
	echo "Failed to change directory. Make sure the path exists."
	exit 1
}

echo "Content inside square brackets has been removed from all .txt files."

# Loop through all .txt files in this directory
for txt_file in *.txt; do
	sed -i '' 's/\[[^][]*\]//g' "$txt_file"
	sed -i '' 's/#//g' "$txt_file"
	$PYTHON_ENV "$SCRIPT_PATH/tts_edge.py" "$txt_file"
	# Uncomment the next line if you need to run the second script
	# $PYTHON_ENV "$SCRIPT_PATH/tts_openai.py" "$txt_file"
done

# Find and move all .mp3 files to the specified directory
find . -type f -name "*.mp3" -exec mv {} "$MP3_DESTINATION" \;

echo "All operations completed successfully."
