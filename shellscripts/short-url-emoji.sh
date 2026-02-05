#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Shorten URL with Emojis
# @raycast.mode compact
# @raycast.packageName Browsing

# Optional parameters:
# @raycast.icon 🔗

# Documentation:
# @raycast.author Samuel Henry
# @raycast.authorURL https://bne.sh
# @raycast.description Transform the clipboard contents to a short Emoji URL

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

regex='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
pasteboardString=$(pbpaste_cmd)

if [[ $pasteboardString =~ $regex ]]
then
	result=$(curl "https://bne.sh/api/shorten?url=$pasteboardString")
    echo $result | ruby -r json -e 'puts JSON.parse(STDIN.read)["url"]' | pbcopy_cmd; echo -n "$(pbpaste_cmd)"
else
	echo "String in clipboard is a not valid URL"
	exit 1
fi
