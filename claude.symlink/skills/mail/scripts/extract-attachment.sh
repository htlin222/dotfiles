#!/bin/bash
# extract-attachment.sh — Extract attachments from an email via Mail.app
# Usage: extract-attachment.sh "<message-id>" [output-dir]
# Returns: paths of saved attachment files, one per line
# If output-dir is omitted, defaults to /tmp/mail-attachments/

MESSAGE_ID="$1"
OUTPUT_DIR="${2:-/tmp/mail-attachments}"

if [ -z "$MESSAGE_ID" ]; then
  echo "Usage: extract-attachment.sh <message-id> [output-dir]" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

# Fetch raw MIME source from Mail.app
MIME_SOURCE=$(osascript -e "
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
" 2>/dev/null)

if [ -z "$MIME_SOURCE" ]; then
  echo "Message not found: $MESSAGE_ID" >&2
  exit 1
fi

# Parse MIME and extract attachments using Python
echo "$MIME_SOURCE" | python3 -c "
import email
import email.policy
import base64
import os
import sys
import re

output_dir = '$OUTPUT_DIR'
raw = sys.stdin.buffer.read()
msg = email.message_from_bytes(raw, policy=email.policy.default)

found = 0
for part in msg.walk():
    content_disposition = part.get('Content-Disposition', '')
    content_type = part.get_content_type()

    # Skip text parts (body) unless they are explicitly attachments
    if 'attachment' not in content_disposition and 'inline' not in content_disposition:
        continue
    if content_type in ('text/plain', 'text/html') and 'attachment' not in content_disposition:
        continue

    filename = part.get_filename()
    if not filename:
        # Generate a name from content type
        ext = content_type.split('/')[-1] if '/' in content_type else 'bin'
        filename = f'attachment_{found}.{ext}'

    # Decode RFC2047 encoded filenames
    if '=?' in filename:
        decoded_parts = email.header.decode_header(filename)
        filename = ''.join(
            part.decode(enc or 'utf-8') if isinstance(part, bytes) else part
            for part, enc in decoded_parts
        )

    # Sanitize filename
    filename = re.sub(r'[/\\\\:]', '_', filename)

    payload = part.get_payload(decode=True)
    if payload:
        filepath = os.path.join(output_dir, filename)
        with open(filepath, 'wb') as f:
            f.write(payload)
        print(filepath)
        found += 1

if found == 0:
    print('No attachments found', file=sys.stderr)
"
