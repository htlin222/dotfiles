---
name: todoist
description: CRUD operations on the user's Todoist — list/create/update/close/delete tasks, projects, sections, labels, and comments via the Todoist API v1. Use when the user asks about Todoist, their todo list, adding/completing/rescheduling a task, managing projects or labels, or says things like "加到待辦", "今天的 Todoist", "把這個工作排到 Todoist".
allowed-tools: Bash(python3 *)
---

# Todoist CRUD

Wraps the Todoist REST API v1 via a bundled Python script. Authentication token lives in `${CLAUDE_SKILL_DIR}/.apikey` (or `TODOIST_API_TOKEN` env var, which takes precedence).

## Invocation

Call the script with `python3`:

```bash
python3 ~/.claude/skills/todoist/scripts/todoist.py <resource> <action> [args...]
```

Resources: `tasks`, `projects`, `sections`, `labels`, `comments`. Every successful call prints the API response as JSON; errors print `HTTP <code>` to stderr and exit non-zero.

For full endpoint/parameter details see [references/api-reference.md](references/api-reference.md).

## Common playbooks

### Add a task (the 90% case)

```bash
python3 ~/.claude/skills/todoist/scripts/todoist.py tasks add "買牛奶" --due "tomorrow 9am" --priority 2
```

- `--due` accepts Todoist natural-language strings (`today`, `tomorrow 9am`, `every monday`, `2026-05-01`).
- `--due-lang` if the user wrote Chinese natural-language (e.g. `"下週二"` → add `--due-lang zh`).
- `--priority` is 1 (lowest) to 4 (highest, p1 in the Todoist UI).
- `--labels` is comma-separated, e.g. `--labels work,urgent`.
- `--project-id` to target a specific project. Resolve project name → id with `projects list` first.

### See today's tasks

```bash
python3 ~/.claude/skills/todoist/scripts/todoist.py tasks list --filter "today"
```

Other filter strings: `overdue`, `7 days`, `p1`, `@work`, `#Inbox`.

### Complete a task

```bash
python3 ~/.claude/skills/todoist/scripts/todoist.py tasks close <task_id>
```

Use `reopen` to un-complete, `delete` to remove entirely.

### Reschedule / edit

```bash
python3 ~/.claude/skills/todoist/scripts/todoist.py tasks update <task_id> --due "friday"
python3 ~/.claude/skills/todoist/scripts/todoist.py tasks update <task_id> --content "new title" --priority 3
```

Only pass the flags you want to change — omitted fields are left untouched.

### Project / label bookkeeping

```bash
# projects
python3 ~/.claude/skills/todoist/scripts/todoist.py projects list
python3 ~/.claude/skills/todoist/scripts/todoist.py projects add "Side project"

# labels
python3 ~/.claude/skills/todoist/scripts/todoist.py labels list
python3 ~/.claude/skills/todoist/scripts/todoist.py labels add "deep-work"
```

## Workflow guidance

1. **Resolve names before acting.** Todoist uses numeric IDs. When the user names a project/label/task, first `list` the relevant resource, match by `name`/`content`, then act on the `id`.
2. **Confirm before destructive ops.** `delete` is irreversible. Confirm with the user when unsure. `close`/`archive` are reversible and safer defaults.
3. **Prefer `close` over `delete`** for completed tasks — it preserves history.
4. **Dates:** pass what the user said verbatim to `--due` (e.g. `"tomorrow 3pm"`, `"下週一"`). The API parses it. Set `--due-lang` when the user wrote non-English.
5. **Soft-delete:** `DELETE` flips `is_deleted: true`; a follow-up `GET` returns **200** with the tombstone, not 404. The script detects this and exits **2** with a stderr warning while still printing the JSON. Treat exit 2 as "gone", not success — don't trust only stdout.
6. **Token errors:** if the script exits with `HTTP 401` or `HTTP 403`, the token is missing/invalid — tell the user to regenerate it at Todoist Settings → Integrations → Developer and write it to `~/.claude/skills/todoist/.apikey`.
7. **Rate limits:** Todoist allows ~450 requests / 15 min per user. For bulk operations, batch via `tasks list --ids "1,2,3"` instead of looping `get`.

## Token file

Stored at `~/.claude/skills/todoist/.apikey`, permissions `600`. To rotate:

```bash
printf '%s' "<new-token>" > ~/.claude/skills/todoist/.apikey
chmod 600 ~/.claude/skills/todoist/.apikey
```

Or export `TODOIST_API_TOKEN` to override without touching the file.
