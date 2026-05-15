# Reminders (Premium-gated for writes)

This file is **not loaded by default**. The `reminders add`/`update` endpoints return `HTTP 403 PREMIUM_ONLY` on the user's account (verified 2026-05-05). For Free-tier workflows, see the "Free-tier workaround" section in the main `SKILL.md`. Load this file only after the user upgrades to Premium, or for the read-side ops (`list`/`get`/`delete`) which do work on Free.

## CLI

```bash
# list (works on any tier)
python3 "${CLAUDE_SKILL_DIR}/scripts/todoist.py" reminders list

# add — relative (N minutes before task due time) — Premium-only
python3 "${CLAUDE_SKILL_DIR}/scripts/todoist.py" reminders add --task-id <id> --type relative --minute-offset 30

# add — absolute (specific datetime, independent of task due) — Premium-only
python3 "${CLAUDE_SKILL_DIR}/scripts/todoist.py" reminders add --task-id <id> --type absolute \
  --due-date "2026-12-31T09:00:00" --due-string "2026-12-31 9am"

python3 "${CLAUDE_SKILL_DIR}/scripts/todoist.py" reminders delete <reminder_id>
```

## Notes

- **Asymmetric naming**: request body uses `task_id`; the response object surfaces it as `item_id`. The CLI flag is `--task-id` to match the request side.
- **Premium gate**: `reminders add`/`update` return `HTTP 403 PREMIUM_ONLY` on Free (verified 2026-05-05). `list`/`get`/`delete` work on any tier — on Free you can audit and clean up auto-created reminders, but can't add new ones via API.
- The user has ~21 auto-created relative reminders (one per task with a due time). Don't add a redundant one before checking `reminders list --task-id` semantics for that task.

## When this becomes relevant again

- User upgrades to Todoist Premium → re-enable the section in `SKILL.md`.
- User explicitly asks to inspect or delete an existing reminder → load this file (read paths still work).
