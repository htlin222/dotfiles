# Todoist API v1 — endpoint reference

Base URL: `https://api.todoist.com/api/v1`
Auth: `Authorization: Bearer <token>` on every request.

## Tasks

| Method | Path | Purpose |
| --- | --- | --- |
| `GET` | `/tasks` | List active tasks. Query: `project_id`, `section_id`, `label`, `filter`, `lang`, `ids` |
| `GET` | `/tasks/{id}` | Fetch one task |
| `POST` | `/tasks` | Create task |
| `POST` | `/tasks/{id}` | Update task (partial — omitted fields untouched) |
| `POST` | `/tasks/{id}/close` | Mark complete |
| `POST` | `/tasks/{id}/reopen` | Un-complete |
| `DELETE` | `/tasks/{id}` | Hard delete |

**Create/update body fields:**

| Field | Type | Notes |
| --- | --- | --- |
| `content` | string | Task title (required on create) |
| `description` | string | Multi-line details |
| `project_id` | string | Target project; default = Inbox |
| `section_id` | string | Section inside project |
| `parent_id` | string | Parent task — makes this a subtask |
| `priority` | int 1–4 | 4 = p1 in UI (highest) |
| `due_string` | string | Natural language: `today`, `tomorrow 9am`, `every mon`, `2026-05-01` |
| `due_date` | string | ISO `YYYY-MM-DD`; use instead of `due_string` for exact date |
| `due_lang` | string | `en`, `zh`, `ja`, … — parser locale |
| `labels` | `[string]` | Label **names**, not IDs |
| `duration` | int | Amount |
| `duration_unit` | `"minute"` or `"day"` | Pairs with `duration` |

**Filter query examples** (pass via `--filter`):

- `today` — due today
- `overdue`
- `7 days` — due in next week
- `p1` — priority 1 (highest)
- `@label_name` — has label
- `#Project name`
- `!assigned to: others`
- Combine with `&` / `|` — e.g. `today & p1`

## Projects

| Method | Path | Purpose |
| --- | --- | --- |
| `GET` | `/projects` | List all |
| `GET` | `/projects/{id}` | One |
| `POST` | `/projects` | Create |
| `POST` | `/projects/{id}` | Update |
| `DELETE` | `/projects/{id}` | Delete |
| `POST` | `/projects/{id}/archive` | Archive |
| `POST` | `/projects/{id}/unarchive` | Restore |

Body: `name` (req. on create), `parent_id`, `color`, `is_favorite`, `view_style` (`list`/`board`).

Color names: `berry_red`, `red`, `orange`, `yellow`, `olive_green`, `lime_green`, `green`, `mint_green`, `teal`, `sky_blue`, `light_blue`, `blue`, `grape`, `violet`, `lavender`, `magenta`, `salmon`, `charcoal`, `grey`, `taupe`.

## Sections

| Method | Path | Purpose |
| --- | --- | --- |
| `GET` | `/sections?project_id={id}` | List (optionally filtered) |
| `GET` | `/sections/{id}` | One |
| `POST` | `/sections` | Create — needs `name` + `project_id` |
| `POST` | `/sections/{id}` | Rename (body: `name`) |
| `DELETE` | `/sections/{id}` | Delete |

## Labels (personal)

| Method | Path | Purpose |
| --- | --- | --- |
| `GET` | `/labels` | List |
| `GET` | `/labels/{id}` | One |
| `POST` | `/labels` | Create |
| `POST` | `/labels/{id}` | Update |
| `DELETE` | `/labels/{id}` | Delete |

Body: `name`, `color`, `order`, `is_favorite`.

## Comments

| Method | Path | Purpose |
| --- | --- | --- |
| `GET` | `/comments?task_id=...` or `?project_id=...` | List |
| `GET` | `/comments/{id}` | One |
| `POST` | `/comments` | Create (body needs `content` + one of `task_id`/`project_id`) |
| `POST` | `/comments/{id}` | Update (body: `content`) |
| `DELETE` | `/comments/{id}` | Delete |

File attachments are supported via the `attachment` object — not wrapped in this skill; use `curl` directly if needed.

## Errors

- `400` — bad body (check required fields, enum values)
- `401` — token missing/invalid
- `403` — token lacks scope, or resource not yours
- `404` — resource was never created (or, in some shapes, not yours)
- `429` — rate limited; ~450 req / 15 min window per user. Back off and retry.
- `5xx` — Todoist side; retry with backoff.

## Soft-delete semantics

`DELETE` does **not** purge — it flips `is_deleted: true`. Follow-up behavior:

- `GET /tasks/{id}` on a deleted task returns **200** with `"is_deleted": true` (not 404).
- `list` endpoints filter out `is_deleted` rows automatically — a deleted task won't appear in `GET /tasks`.
- Second `DELETE` on the same id returns 204 (idempotent).
- `close`/`reopen`/`update` on a deleted task typically fail or no-op; don't rely on it.

The bundled `todoist.py` detects `is_deleted: true` on any GET response, writes a warning to stderr, and exits with code **2** (stdout still contains the JSON body). Check the exit code, not just stdout, when you need to know whether the resource is live.

## Sync API (not wrapped)

Todoist also offers a Sync API (`/sync/v9/sync`) for batch/atomic operations and offline clients. This skill uses only the REST v1 surface since individual CRUD is simpler and enough for almost all interactive needs.
