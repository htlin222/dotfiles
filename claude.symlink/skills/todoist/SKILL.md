---
name: todoist
description: CRUD operations on the user's Todoist — list/create/update/close/delete tasks (incl. due + deadline), projects, sections, labels, comments, and reminders via the Todoist API v1. Use when the user asks about Todoist, their todo list, adding/completing/rescheduling a task, setting a deadline or reminder, managing projects or labels, or says things like "加到待辦", "今天的 Todoist", "把這個工作排到 Todoist".
allowed-tools: Bash(python3 *)
---

# Todoist CRUD

Wraps the Todoist REST API v1 via a bundled Python script. Token: `${CLAUDE_SKILL_DIR}/.apikey` (or `TODOIST_API_TOKEN` env var, takes precedence).

## Path conventions

`${CLAUDE_SKILL_DIR}` = directory holding this `SKILL.md`. Resolve once per shell:

```bash
export CLAUDE_SKILL_DIR=<path reported by the Skill tool's "Base directory">
```

The script self-locates via `__file__`; the env var is only for shell invocations.

## Invocation

```bash
python3 "${CLAUDE_SKILL_DIR}/scripts/todoist.py" <resource> <action> [args...]
```

Resources: `tasks`, `projects`, `sections`, `labels`, `comments`, `reminders`. Successful calls print JSON; errors print `HTTP <code>` to stderr and exit non-zero.

## References (load on demand)

- [references/api-reference.md](references/api-reference.md) — endpoint matrix, body fields, date-parsing notes, Premium-only details, Sync API (filters), error codes, soft-delete semantics
- [references/filter-system.md](references/filter-system.md) — the user's deliberate 8-filter / label system. **Source of truth** for "what should I do now?" / weekly review / prioritization questions
- [references/reminders.md](references/reminders.md) — reminders write API (Premium-gated; load when user upgrades or for read-side audit)

## Common playbooks

### Add a task

```bash
python3 "${CLAUDE_SKILL_DIR}/scripts/todoist.py" tasks add "買牛奶" --due "tomorrow 9am" --priority 2
```

- `--due` accepts English natural-language or `YYYY-MM-DD`. **Chinese relative dates fail** — resolve to absolute date yourself before calling. Details in `api-reference.md` § Date parsing notes.
- `--priority` 1 (lowest) → 4 (highest, p1 in UI).
- `--labels` comma-separated.
- `--project-id` to target a project (resolve name → id with `projects list`).

### Today's tasks

```bash
python3 "${CLAUDE_SKILL_DIR}/scripts/todoist.py" tasks list --filter "today"
```

Filter strings: `overdue`, `7 days`, `p1`, `@label`, `#Project`. Combine with `&` `|`.

### Complete / reschedule / edit

```bash
python3 "${CLAUDE_SKILL_DIR}/scripts/todoist.py" tasks close <id>
python3 "${CLAUDE_SKILL_DIR}/scripts/todoist.py" tasks update <id> --due "friday"
python3 "${CLAUDE_SKILL_DIR}/scripts/todoist.py" tasks update <id> --content "new title" --priority 3
```

`reopen` to un-complete, `delete` to remove. Update only flags you pass — omitted fields untouched.

### Premium-only operations

`--deadline-date` (tasks) and `reminders add`/`update` return **HTTP 403 PREMIUM_ONLY** on Free. **Don't call.** Free-tier substitutes:

- Day-of reminder → just `--due "YYYY-MM-DD HH:MM"` (Todoist auto-creates the reminder).
- T-N pre-event nudge → create a separate prep task due on the T-N date.

Full Premium-gate behavior + read-side ops (work on Free): see `api-reference.md` § Premium-only writes and `references/reminders.md`.

### Project / label bookkeeping

```bash
python3 "${CLAUDE_SKILL_DIR}/scripts/todoist.py" projects list
python3 "${CLAUDE_SKILL_DIR}/scripts/todoist.py" projects add "Side project"
python3 "${CLAUDE_SKILL_DIR}/scripts/todoist.py" labels list
python3 "${CLAUDE_SKILL_DIR}/scripts/todoist.py" labels add "deep-work"
```

## Workflow guidance

1. **Resolve names → IDs first.** Todoist uses numeric IDs. `list` the resource, match by `name`/`content`, act on the `id`.
2. **`close` > `delete`** for completed tasks (preserves history). Confirm before `delete` — irreversible.
3. **Soft-delete:** `DELETE` flips `is_deleted: true`; subsequent `GET` returns 200 with tombstone. Script exits **2** with stderr warning. Treat exit 2 as "gone".
4. **Token errors (HTTP 401/403):** regenerate at Todoist Settings → Integrations → Developer; write to `${CLAUDE_SKILL_DIR}/.apikey`.
5. **Rate limit:** ~450 req / 15 min. For bulk reads, prefer `tasks list --ids "1,2,3"` over loops of `get`.

## Token file

`${CLAUDE_SKILL_DIR}/.apikey`, mode `600`. Rotate:

```bash
printf '%s' "<new-token>" > "${CLAUDE_SKILL_DIR}/.apikey"
chmod 600 "${CLAUDE_SKILL_DIR}/.apikey"
```

Or `export TODOIST_API_TOKEN=...` to override without touching the file.
