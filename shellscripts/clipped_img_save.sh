#!/bin/bash
# title: clip_save
# date created: "2023-10-12"

#!/bin/bash
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Save Clipboard to Smear
# @raycast.mode silent
#
# Optional parameters:
# @raycast.icon 🩸
#
# Documentation:
# @raycast.description This script takes image in the file and save it to the smear folder.
# @raycast.author Hsiehting Lin
# @raycast.authorURL https://github.com/htlin22

# Get the current date and time

datetime=$(date +"%Y%m%d%H%M%S")

# Save the clipboard image as a JPEG file with a timestamped file name
pngpaste - | convert - $HOME/Documents/images/smear/$datetime.jpg

# Check if the file was saved successfully
if [ -f "$HOME/Documents/images/smear/$datetime.jpg" ]; then
    echo "Clipboard image saved successfully."
    open $HOME/Documents/images/smear/
    # 等待Finder窗口打開
    sleep 2
    osascript <<EOF
tell application "Finder"
    set the bounds of the front window to {0, 0, 800, 800}
    set current view of front window to icon view -- 切換到圖像模式
end tell
EOF
else
    echo "Error saving clipboard image."
fi
