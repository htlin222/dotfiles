#!/bin/bash
# extract-urls.sh — Extract URLs from an email's HTML source via Mail.app
# Usage: extract-urls.sh "<message-id>"
# Returns: one URL per line, filtered to remove tracking pixels and common assets

MESSAGE_ID="$1"

if [ -z "$MESSAGE_ID" ]; then
  echo "Usage: extract-urls.sh <message-id>" >&2
  exit 1
fi

# Fetch raw MIME source from Mail.app, decode base64 HTML, extract URLs
osascript -e "
tell application \"Mail\"
    set targetId to \"$MESSAGE_ID\"
    repeat with acct in accounts
        repeat with mb in mailboxes of acct
            try
                set msgs to (messages of mb whose message id is targetId)
                if (count of msgs) > 0 then
                    set msg to item 1 of msgs
                    return source of msg
                end if
            end try
        end repeat
    end repeat
    return \"\"
end tell
" 2>/dev/null | \
  # Extract base64 blocks from text/html parts and decode them
  sed -n '/Content-Type: text\/html/,/^--/p' | \
  grep -v '^Content-\|^MIME-\|^--' | \
  base64 -d 2>/dev/null | \
  # Extract href URLs
  grep -oE 'href="(https?://[^"]+)"' | \
  sed 's/href="//;s/"$//' | \
  # Filter out common non-actionable URLs (images, tracking, unsubscribe, social)
  grep -viE '\.(png|jpg|jpeg|gif|svg|ico|css|js)(\?|$)' | \
  grep -viE 'unsubscribe|tracking|click\.|pixel|beacon|facebook\.com|instagram\.com|twitter\.com|linkedin\.com|youtube\.com' | \
  grep -viE 'mailto:' | \
  # Deduplicate while preserving order
  awk '!seen[$0]++'
