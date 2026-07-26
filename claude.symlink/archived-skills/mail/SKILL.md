---
name: mail
description: Read Mail.app inboxes and create Reminders for actionable items. Use for email triage.
---

# Mail Processor

Reads macOS Mail.app, identifies actionable emails, and creates reminders in Reminders.app "Inbox" list.

## Usage

- `/mail` — process past 24 hours (default)
- `/mail 7 days` — process past 7 days
- `/mail 14 days` — process past 14 days

## Workflow

### Batch A: Fetch Everything (PARALLEL)

**Issue ALL of these tool calls in a single parallel message:**

1. **Bash** — Activate apps + fetch emails (combined to avoid extra round-trip):

   ```bash
   osascript -e 'tell application "Mail" to activate' && osascript -e 'tell application "Reminders" to activate' && sleep 1 && osascript ~/.claude/skills/mail/scripts/fetch-mail.applescript <days>
   ```

   - Default `<days>` is 1. If user provides args like "7 days", "48h", or "14 days", extract the number.
   - Returns JSON array. Each email object has: `id`, `account`, `subject`, `from`, `date`, `read`, `preview`.

2. **Read** — Load dedup database from `/tmp/mail-already-processed.json`:
   - If the file does not exist (Read fails/hook blocks), initialize it:
     - **Write** `/tmp/mail-already-processed.json` with: `{"processed_ids":[],"last_run":""}`
     - Then **Read** it

3. **Bash** — Fetch existing reminders for dedup:
   ```bash
   ~/.claude/skills/mail/scripts/reminders-cli fetch
   ```

**After Batch A completes**, filter out emails whose `id` is already in `processed_ids`. Only analyze NEW emails.

### Step B: Analyze Emails for Actionable Items

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
- **body**: Key details — who sent it, what's needed, any action URLs (see Batch C)
- **due**: Best estimate of deadline in "YYYY-MM-DD HH:MM" format. If no explicit deadline, set reasonable default (e.g., next business day for requests, meeting time for prep)
- **priority**: 1 (high/urgent), 5 (medium/normal), 9 (low/FYI)

### Batch C: Extract URLs (PARALLEL)

**Issue ALL extract-urls.sh calls in a single parallel message** — one Bash tool call per actionable email:

```bash
~/.claude/skills/mail/scripts/extract-urls.sh "<message-id>"
```

Returns one URL per line, filtered to remove tracking pixels, images, and social media links.

**How to use extracted URLs**:

- Include the most relevant action URL in the reminder **body** (e.g., sign-off links, registration URLs, form links)
- If multiple URLs are returned, pick the one most relevant to the required action (e.g., a token/report URL, not the homepage)
- Show actionable URLs in the summary report under a **Link** column

**Performance note**: Only run this for actionable emails (typically 1-5 per batch). Each call takes ~2-3s but they run in parallel, so total wall time ≈ one call.

### Step D: Deduplicate Against Existing Reminders

Before adding, check if a similar reminder already exists (from Batch A's reminders fetch) by comparing:

- Exact or fuzzy match on reminder name
- Same due date
- Similar body content (e.g., same sender + same topic)

Skip any reminder that would be a duplicate.

### Step E: Add Reminders (BATCH)

Use the batch-add command to create all reminders in a single process invocation:

```bash
printf '%s' '<JSON_ARRAY>' | ~/.claude/skills/mail/scripts/reminders-cli batch-add
```

Where `<JSON_ARRAY>` is a JSON array of objects:

```json
[
  {
    "name": "Task title",
    "body": "Details and context",
    "due": "YYYY-MM-DD HH:MM",
    "priority": "1"
  },
  {
    "name": "Another task",
    "body": "More details",
    "due": "YYYY-MM-DD HH:MM",
    "priority": "5"
  }
]
```

Priority values: `"1"` (high/urgent), `"5"` (medium/normal), `"9"` (low/FYI).

Returns `OK:<count>` on success.

**Shell escaping**: The JSON must be valid. Use `printf '%s'` to pipe JSON to stdin. Avoid single quotes inside the JSON — use escaped double quotes for string values.

**Fallback**: If batch-add fails, fall back to individual `reminders-cli add` calls — issue them ALL in a single parallel message:

```bash
~/.claude/skills/mail/scripts/reminders-cli add "<name>" "<body>" "<due_date>" "<priority>"
```

### Step F: Update Dedup Database

After processing, update `/tmp/mail-already-processed.json`:

- Add all newly processed email IDs (both actionable and non-actionable) to `processed_ids`
- Update `last_run` timestamp
- Keep only IDs from the last 30 days to prevent unbounded growth

Use the **Write** tool (not bash heredoc/redirect) to write the updated JSON:

```json
{
  "processed_ids": ["id1", "id2", ...],
  "last_run": "2026-03-10T00:00:00"
}
```

**Important**: Do NOT use `cat > file << EOF` — the `check-file-exists` hook will block the `>` redirect. Always use the Write tool for this file.

### Step G: Report Summary

Present results to user in a table:

```
## Mail Summary (past <N> days)

**Processed**: X new emails across Y accounts
**Skipped**: Z already-processed emails

### Actionable Items Added to Reminders:

| # | Due | Reminder | Priority | Source | Link |
|---|-----|----------|----------|--------|------|
| 1 | 3/9 12:00 | Task name | HIGH | sender@email.com | [action link](url) |

### Non-Actionable (skipped):
- Newsletter from X
- Notification from Y
```

If no actionable URL was found for an item, show "—" in the Link column.

## Notes

- The user's Mail.app has accounts: iCloud, 一般, 正式, 和信, Exchange
- Inbox mailbox names vary: "INBOX" (IMAP) and "收件匣" (Exchange/localized)
- Reminders go to the "Inbox" list in Reminders.app
- Language: emails may be in English, Chinese (Traditional), or Japanese — handle all
- The dedup file at `/tmp/mail-already-processed.json` persists across reboots only if /tmp is not cleaned. This is acceptable — reprocessing is harmless since we also check existing reminders.
