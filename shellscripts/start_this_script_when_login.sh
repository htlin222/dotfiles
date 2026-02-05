#!/bin/bash
# title: start_this_script_when_login
# date created: "2023-06-13"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./shellscripts/lib.sh
source "$SCRIPT_DIR/lib.sh"

if ! is_mac; then
    echo "This script is macOS-only." >&2
    exit 1
fi

# Check if the shell script name is provided as an argument
if [ -z "$1" ]; then
    echo "Please provide the path to the shell script as an argument."
    exit 1
fi

# Get the absolute path to the shell script
SCRIPT_PATH="$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"

# Create the plist content
PLIST_CONTENT="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple Computer//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:</string>
    </dict>
    <key>Label</key>
    <string>com.startup.$(basename "$1" .sh)</string>
    <key>Program</key>
    <string>$SCRIPT_PATH</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
    <key>LaunchOnlyOnce</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/startup.stdout</string>
    <key>StandardErrorPath</key>
    <string>/tmp/startup.stderr</string>
    <key>UserName</key>
    <string>$USER</string>
</dict>
</plist>"

# Create the LaunchAgents directory if it doesn't exist
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
mkdir -p "$LAUNCH_AGENTS_DIR"

# Determine the plist file path
PLIST_FILE_PATH="$LAUNCH_AGENTS_DIR/$(basename "$1" .sh).plist"

# Write the plist content to the file
echo "$PLIST_CONTENT" > "$PLIST_FILE_PATH"

# Set executable permissions to the shell script
chmod +x "$SCRIPT_PATH"

# Load the plist file using launchctl
launchctl load -w "$PLIST_FILE_PATH"

# Provide feedback to the user
if [ $? -eq 0 ]; then
    echo "Script loaded successfully."
else
    echo "Failed to load the script."
fi
