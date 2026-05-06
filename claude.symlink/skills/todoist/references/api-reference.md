# Todoist API v1 — endpoint reference

Base URL: `https://api.todoist.com/api/v1`
Auth: `Authorization: Bearer <token>` on every request.

## Tasks

| Method   | Path                 | Purpose                                                                                |
| -------- | -------------------- | -------------------------------------------------------------------------------------- |
| `GET`    | `/tasks`             | List active tasks. Query: `project_id`, `section_id`, `label`, `filter`, `lang`, `ids` |
| `GET`    | `/tasks/{id}`        | Fetch one task                                                                         |
| `POST`   | `/tasks`             | Create task                                                                            |
| `POST`   | `/tasks/{id}`        | Update task (partial — omitted fields untouched)                                       |
| `POST`   | `/tasks/{id}/close`  | Mark complete                                                                          |
| `POST`   | `/tasks/{id}/reopen` | Un-complete                                                                            |
| `DELETE` | `/tasks/{id}`        | Hard delete                                                                            |

**Create/update body fields:**

| Field           | Type                  | Notes                                                                |
| --------------- | --------------------- | -------------------------------------------------------------------- |
| `content`       | string                | Task title (required on create)                                      |
| `description`   | string                | Multi-line details                                                   |
| `project_id`    | string                | Target project; default = Inbox                                      |
| `section_id`    | string                | Section inside project                                               |
| `parent_id`     | string                | Parent task — makes this a subtask                                   |
| `priority`      | int 1–4               | 4 = p1 in UI (highest)                                               |
| `due_string`    | string                | Natural language: `today`, `tomorrow 9am`, `every mon`, `2026-05-01` |
| `due_date`      | string                | ISO `YYYY-MM-DD`; use instead of `due_string` for exact date         |
| `due_lang`      | string                | `en`, `zh`, `ja`, … — parser locale                                  |
| `deadline_date` | string                | ISO `YYYY-MM-DD`. Distinct from `due_*`. **Premium-only**            |
| `deadline_lang` | string                | Parser locale for deadline                                           |
| `labels`        | `[string]`            | Label **names**, not IDs                                             |
| `duration`      | int                   | Amount                                                               |
| `duration_unit` | `"minute"` or `"day"` | Pairs with `duration`                                                |

**`due` vs `deadline`**: due = "when I plan to work on it" (shows in Today/Upcoming); deadline = "when it must be done by" (separate UI affordance). Tasks can have both, neither, or either alone. Free tier: writes containing `deadline_date` return `HTTP 403 PREMIUM_ONLY` (error_code 32, observed 2026-05-05). Reads of pre-existing deadlines are unrestricted.

### Date parsing notes

- `--due` / `due_string` accepts Todoist natural-language: `today`, `tomorrow 9am`, `every monday`, `2026-05-01`. Absolute `YYYY-MM-DD` always works.
- `--due-lang zh` is **documented** to take Chinese natural-language but **the API rejects most relative forms** (e.g. `"下週五"` → `HTTP 400 BAD_REQUEST: Invalid date format`, observed 2026-05-02). **Resolve Chinese relative dates yourself before calling** — convert `"下週五"` from a Sat → `2026-05-08`, then keep the user's original phrasing in the task content for context. Reserve `--due-lang zh` for verified-working forms only (none confirmed yet).

### Premium-only writes (deadlines, reminders)

Free tier returns `HTTP 403 PREMIUM_ONLY` (error_code 32, observed 2026-05-05) on:

- any task `POST` containing `deadline_date` / `deadline_lang`
- `POST /reminders` (create or update)

Reads of pre-existing deadlines/reminders are **unrestricted**. Free-tier substitutes for the write paths:

- **Day-of reminder** → set `due_string` with a time component (`"2026-05-10 17:00"`); Todoist auto-creates a relative reminder.
- **T-N pre-event nudge** → create a separate prep task whose own due date is the T-N day.

For the reminders write API (when the user upgrades), see `references/reminders.md`.

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

| Method   | Path                       | Purpose  |
| -------- | -------------------------- | -------- |
| `GET`    | `/projects`                | List all |
| `GET`    | `/projects/{id}`           | One      |
| `POST`   | `/projects`                | Create   |
| `POST`   | `/projects/{id}`           | Update   |
| `DELETE` | `/projects/{id}`           | Delete   |
| `POST`   | `/projects/{id}/archive`   | Archive  |
| `POST`   | `/projects/{id}/unarchive` | Restore  |

Body: `name` (req. on create), `parent_id`, `color`, `is_favorite`, `view_style` (`list`/`board`).

Color names: `berry_red`, `red`, `orange`, `yellow`, `olive_green`, `lime_green`, `green`, `mint_green`, `teal`, `sky_blue`, `light_blue`, `blue`, `grape`, `violet`, `lavender`, `magenta`, `salmon`, `charcoal`, `grey`, `taupe`.

## Sections

| Method   | Path                        | Purpose                              |
| -------- | --------------------------- | ------------------------------------ |
| `GET`    | `/sections?project_id={id}` | List (optionally filtered)           |
| `GET`    | `/sections/{id}`            | One                                  |
| `POST`   | `/sections`                 | Create — needs `name` + `project_id` |
| `POST`   | `/sections/{id}`            | Rename (body: `name`)                |
| `DELETE` | `/sections/{id}`            | Delete                               |

## Labels (personal)

| Method   | Path           | Purpose |
| -------- | -------------- | ------- |
| `GET`    | `/labels`      | List    |
| `GET`    | `/labels/{id}` | One     |
| `POST`   | `/labels`      | Create  |
| `POST`   | `/labels/{id}` | Update  |
| `DELETE` | `/labels/{id}` | Delete  |

Body: `name`, `color`, `order`, `is_favorite`.

## Comments

| Method   | Path                                         | Purpose                                                       |
| -------- | -------------------------------------------- | ------------------------------------------------------------- |
| `GET`    | `/comments?task_id=...` or `?project_id=...` | List                                                          |
| `GET`    | `/comments/{id}`                             | One                                                           |
| `POST`   | `/comments`                                  | Create (body needs `content` + one of `task_id`/`project_id`) |
| `POST`   | `/comments/{id}`                             | Update (body: `content`)                                      |
| `DELETE` | `/comments/{id}`                             | Delete                                                        |

File attachments are supported via the `attachment` object — not wrapped in this skill; use `curl` directly if needed.

## Reminders

| Method   | Path              | Purpose                             |
| -------- | ----------------- | ----------------------------------- |
| `GET`    | `/reminders`      | List (paginated: `cursor`, `limit`) |
| `GET`    | `/reminders/{id}` | One                                 |
| `POST`   | `/reminders`      | Create                              |
| `POST`   | `/reminders/{id}` | Update                              |
| `DELETE` | `/reminders/{id}` | Delete                              |

**Asymmetric naming**: request body uses `task_id`; response object surfaces it as `item_id`. Same id; different field name across the two directions.

**Body fields:**

| Field           | Type   | Notes                                                                                                        |
| --------------- | ------ | ------------------------------------------------------------------------------------------------------------ |
| `task_id`       | string | Target task. Required on create. Surfaces as `item_id` in response                                           |
| `type`          | string | `relative` \| `absolute` \| `location`                                                                       |
| `minute_offset` | int    | Minutes before task due time (relative type). All 21 of user's auto-created reminders use `minute_offset: 0` |
| `notify_uid`    | string | User to notify; defaults to self                                                                             |
| `due`           | object | For absolute type: `{date, string, lang, timezone}`                                                          |

**Premium gate**: `POST` to `/reminders` (create or update) returns `HTTP 403 PREMIUM_ONLY` (error_code 32) on Free tier (verified 2026-05-05). `GET` and `DELETE` work on any tier.

### Location reminders (separate resource)

Endpoints: `/location_reminders` (GET/POST/DELETE same shape). User has 0 of these (verified 2026-05-05). Not wrapped by `todoist.py`; use `curl` directly with `task_id`, `name`, `loc_lat`, `loc_long`, `loc_trigger` (`on_enter`/`on_leave`), `radius`.

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

## Sync API (not wrapped, but reachable directly)

The bundled `todoist.py` covers REST v1 only. Some resources — notably **filters** — are not in REST v1 (`GET /api/v1/filters` returns 404). They live on the Sync API, which is now served at **`POST /api/v1/sync`**.

> ⚠ The legacy endpoint `https://api.todoist.com/sync/v9/sync` is **deprecated** and returns `HTTP 410` with a "use /api/v1/" redirect message. Always hit `/api/v1/sync` instead.

### Filter CRUD via Sync (form-encoded body)

```bash
TOKEN=$(cat "${CLAUDE_SKILL_DIR}/.apikey")
curl -sS -X POST -H "Authorization: Bearer $TOKEN" \
  https://api.todoist.com/api/v1/sync \
  --data-urlencode 'commands=[{"type":"filter_add","temp_id":"<uuid>","uuid":"<uuid>","args":{"name":"My filter","query":"today","is_favorite":true,"item_order":1}}]'
```

Other commands: `filter_update`, `filter_delete`. Same `commands` array shape: each command needs a fresh `uuid`, and `filter_add` also needs a `temp_id`.

### Read existing filters

```bash
curl -sS -X POST -H "Authorization: Bearer $TOKEN" \
  https://api.todoist.com/api/v1/sync \
  --data-urlencode 'sync_token=*' \
  --data-urlencode 'resource_types=["filters"]'
```

Returns `{"filters":[...], ...}`.

### Free-tier filter cap

Todoist Free caps **filters at 5 per user** (observed 2026-05-05; sync_status returns `MAX_FILTERS_LIMIT_REACHED` / `error_code: 52` / `http_code: 403` when exceeded). Pro raises it to 150. If `filter_add` fails with this, either delete an existing filter, fall back to label-click navigation in the sidebar, or upgrade.

### Atomicity

Sync commands process **in array order**, but each gets its own `sync_status` entry. Partial failure is possible: e.g. 8 deletes + 8 adds when cap is 5 → all 8 deletes succeed, then first 5 adds succeed, last 3 fail with `MAX_FILTERS_LIMIT_REACHED`. Order critical/favorite items first.
