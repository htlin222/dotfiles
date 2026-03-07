---
name: mail
description: Reads Mail.app inboxes from all accounts, identifies actionable items, and adds reminders to Reminders.app with deduplication. Use when user asks to check email, process mail, or wants a mail summary. Trigger on "/mail", "check my mail", "email summary".
---

# Mail Processor

Reads macOS Mail.app, identifies actionable emails, and creates reminders in Reminders.app "Inbox" list.

## Usage

- `/mail` — process past 24 hours (default)
- `/mail 7 days` — process past 7 days
- `/mail 14 days` — process past 14 days

## Workflow

### Step 1: Ensure Apps Are Running

```bash
osascript -e 'tell application "Mail" to activate'
osascript -e 'tell application "Reminders" to activate'
```

Wait 2 seconds for apps to initialize.

### Step 2: Parse Time Range

- Default: 1 day
- If user provides args like "7 days" or "14 days", extract the number
- The number is passed as the `<days>` argument to the fetch script

### Step 3: Fetch All Emails

Run the AppleScript to fetch emails from ALL accounts, ALL inboxes (matches both "INBOX" and "收件匣"):

```bash
osascript ~/.claude/skills/mail/scripts/fetch-mail.applescript <days>
```

This returns a JSON array. Each email object has: `id`, `account`, `subject`, `from`, `date`, `read`, `preview`.

**Important**: The output may be large. If it fails or is too slow, reduce the day count or process account-by-account.

### Step 4: Load Dedup Database

Check for previously processed emails:

```bash
cat /tmp/mail-already-processed.json 2>/dev/null || echo '{"processed_ids":[]}'
```

The file structure:
```json
{
  "processed_ids": ["msg-id-1", "msg-id-2"],
  "last_run": "2026-03-08T10:00:00"
}
```

Filter out emails whose `id` is already in `processed_ids`. Only analyze NEW emails.

### Step 5: Fetch Existing Reminders

Get current incomplete reminders from "Inbox" list to avoid content-level duplicates:

```bash
osascript ~/.claude/skills/mail/scripts/fetch-reminders.applescript
```

Returns JSON array with `name`, `body`, `due` fields.

### Step 6: Analyze Emails for Actionable Items

For each new email, determine if it requires action. Classify into:

**Actionable** (create reminder):
- Explicit deadlines or due dates mentioned
- Meeting invitations requiring RSVP or preparation
- Requests addressed to the user (reply needed, form to fill, document to sign)
- System alerts requiring intervention (server down, config errors, expiring accounts)
- Action items with keywords: "please", "action required", "deadline", "due by", "before", "sign", "submit", "reply", "confirm"

**Not actionable** (skip):
- Newsletters, promotional emails, product announcements
- Read receipts, automated notifications (no action needed)
- Already-read informational emails
- Spam, marketing

For each actionable email, extract:
- **name**: Short task description (not the raw subject — rewrite for clarity)
- **body**: Key details — who sent it, what's needed, any links
- **due**: Best estimate of deadline in "YYYY-MM-DD HH:MM" format. If no explicit deadline, set reasonable default (e.g., next business day for requests, meeting time for prep)
- **priority**: 1 (high/urgent), 5 (medium/normal), 9 (low/FYI)

### Step 7: Deduplicate Against Existing Reminders

Before adding, check if a similar reminder already exists by comparing:
- Exact or fuzzy match on reminder name
- Same due date
- Similar body content (e.g., same sender + same topic)

Skip any reminder that would be a duplicate.

### Step 8: Add Reminders

For each new actionable item, run:

```bash
osascript ~/.claude/skills/mail/scripts/add-reminder.applescript "<name>" "<body>" "<due_date>" "<priority>"
```

Where:
- `<name>`: reminder title (keep under 80 chars)
- `<body>`: details and context
- `<due_date>`: format "YYYY-MM-DD HH:MM" or empty string "" for no due date
- `<priority>`: 1, 5, or 9

**Shell escaping**: Be careful with quotes and special characters in name/body. Use single quotes around arguments and escape any internal single quotes.

### Step 9: Update Dedup Database

After processing, update `/tmp/mail-already-processed.json`:
- Add all newly processed email IDs (both actionable and non-actionable) to `processed_ids`
- Update `last_run` timestamp
- Keep only IDs from the last 30 days to prevent unbounded growth

Write the updated JSON:

```bash
cat > /tmp/mail-already-processed.json << 'DEDUP_EOF'
{
  "processed_ids": ["id1", "id2", ...],
  "last_run": "2026-03-08T10:00:00"
}
DEDUP_EOF
```

### Step 10: Report Summary

Present results to user in a table:

```
## Mail Summary (past <N> days)

**Processed**: X new emails across Y accounts
**Skipped**: Z already-processed emails

### Actionable Items Added to Reminders:

| # | Due | Reminder | Priority | Source |
|---|-----|----------|----------|--------|
| 1 | 3/9 12:00 | Task name | HIGH | sender@email.com |

### Non-Actionable (skipped):
- Newsletter from X
- Notification from Y
```

## Notes

- The user's Mail.app has accounts: iCloud, 一般, 正式, 和信, Exchange
- Inbox mailbox names vary: "INBOX" (IMAP) and "收件匣" (Exchange/localized)
- Reminders go to the "Inbox" list in Reminders.app
- Language: emails may be in English, Chinese (Traditional), or Japanese — handle all
- The dedup file at `/tmp/mail-already-processed.json` persists across reboots only if /tmp is not cleaned. This is acceptable — reprocessing is harmless since we also check existing reminders.
