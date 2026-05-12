# DeepSeek webGUI API reference

Internal API surface used by `chat.deepseek.com`. Not officially documented; reverse-engineered from a HAR capture and the shipped JS bundle. Endpoints, header names, and POW algorithm are accurate as of May 2026 (commit `861862c6` of the chat frontend).

## Auth model

Three layers, all required:

1. **`Authorization: Bearer <userToken>`** — long-lived API token. In the browser it lives at `localStorage.userToken` on `chat.deepseek.com`. There is no anonymous mode and no exchange endpoint that mints one from cookies; you must log in via the web UI and copy the value out. Get it via:
   - DevTools → Application → Local Storage → `https://chat.deepseek.com` → key `userToken`, OR
   - DevTools console: `copy(localStorage.userToken)`
2. **Cookies** on `*.deepseek.com`:
   - `aws-waf-token` — required to bypass CloudFront/WAF challenges (status `202 x-amzn-waf-action: challenge` without it).
   - `ds_session_id` — server session cookie (HttpOnly, Secure). Sent automatically by the browser and recommended to send too.
   - The other cookies (`smidV2`, `NEXT_LOCALE`, `.thumbcache_*`) are not required for the `chat/*` API.
3. **Frontend identity headers** — required, value-checked but not signed:
   - `x-app-version: 2.0.0`
   - `x-client-platform: web`
   - `x-client-version: 2.0.0`
   - `x-client-locale: en_US` (or `zh_CN`)
   - `x-client-timezone-offset: 28800`
   - `origin: https://chat.deepseek.com`
   - `referer: https://chat.deepseek.com/`
   - `user-agent`: any plausible Chrome UA

## Standard envelope

Every JSON endpoint wraps payloads as:

```json
{ "code": 0, "msg": "", "data": { "biz_code": 0, "biz_msg": "", "biz_data": { ... } } }
```

Common error codes:
- `40002 / "Missing Token"` — Authorization header missing or rejected.
- WAF: returns `202 Accepted` with HTML body, header `x-amzn-waf-action: challenge`. Resolve `aws-waf-token` and retry.

## POST `/api/v0/chat_session/create`

Creates an empty chat session. Body: `{}`. Response payload:
```json
{
  "biz_data": {
    "chat_session": {
      "id": "<uuid>",
      "seq_id": 200514359,
      "agent": "chat",
      "model_type": "default",
      "title": null,
      "title_type": "WIP",
      "version": 0,
      "current_message_id": null,
      "pinned": false,
      "inserted_at": 1778351159.889,
      "updated_at": 1778351159.889
    },
    "ttl_seconds": 259200
  }
}
```

`chat_session.id` is the value to pass as `chat_session_id` in subsequent requests.

## POST `/api/v0/chat/create_pow_challenge`

Request body: `{"target_path": "/api/v0/chat/completion"}`.

Response:
```json
{
  "biz_data": {
    "challenge": {
      "algorithm": "DeepSeekHashV1",
      "challenge": "<sha256-hex, 64 chars>",
      "salt": "<random hex, 20 chars>",
      "signature": "<sha256-hex, 64 chars>",
      "difficulty": 144000,
      "expire_at": 1778351492367,        // ms epoch
      "expire_after": 300000,             // 5 minutes
      "target_path": "/api/v0/chat/completion"
    }
  }
}
```

The challenge is single-use and tied to `target_path`. Solve, base64-encode, and send the answer in the `x-ds-pow-response` header on the very next request to that path.

## POW algorithm — DeepSeekHashV1

The browser implementation is a SHA3-based WASM solver (file: `static/sha3_wasm_bg.7b9ca65ddd.wasm`). The exported function `wasm_solve(retptr, challenge_ptr, challenge_len, prefix_ptr, prefix_len, difficulty: f64)` writes back `(ok: i32, answer: f64)`. The skill bundles this WASM (`scripts/sha3.wasm`) and drives it via `wasmtime` from Python (`scripts/pow.py`).

Key facts derived from the WASM and confirmed against the captured HAR:

- Prefix string: `f"{salt}_{expire_at}_"` (UTF-8). Note that this is the snake_case `expire_at` value from the response — not anything derived from `signature`.
- The challenge hex string is decoded to 32 bytes inside the WASM.
- The exact iteration / threshold logic is not pure SHA3-256 of the prefix; reproducing it cleanly in Python required several attempts. The pragmatic and correct solution is to call the WASM directly.
- For the captured challenge `9b72b6d3…` / salt `502b4b40…` / difficulty `144000` / expire_at `1778351492367`, the answer is `49586`. The bundled solver matches.

The solved POW header payload:
```json
{
  "algorithm":"DeepSeekHashV1",
  "challenge":"<same as challenge>",
  "salt":"<same as salt>",
  "answer":<integer>,
  "signature":"<same as signature>",
  "target_path":"/api/v0/chat/completion"
}
```
…then base64-encoded and placed in `x-ds-pow-response`.

## POST `/api/v0/chat/completion`

Headers required beyond the standard set:
- `x-ds-pow-response: <base64 of solved POW>`
- `accept: text/event-stream` (optional but conventional)

Request body:
```json
{
  "chat_session_id": "<uuid>",
  "parent_message_id": null,
  "model_type": "default" | "expert",
  "prompt": "your text here",
  "ref_file_ids": [],
  "thinking_enabled": true,
  "search_enabled": true,
  "preempt": false
}
```

- `model_type`: `default` is DeepSeek-V3 (fast). `expert` enables the reasoning model.
- `parent_message_id`: pass the previous assistant message's ID to thread a follow-up. `null` = first turn.
- `thinking_enabled` / `search_enabled` are gates for reasoning-trace and web-search fragments.
- `preempt: true` cancels the current generation (use sparingly).

### Streaming protocol (`text/event-stream`)

Three named event types and a stream of unnamed `data:` frames containing JSON-Patch-like updates:

```
event: ready
data: {"request_message_id":1,"response_message_id":2,"model_type":"expert"}

event: update_session
data: {"updated_at": 1778351160.6133668}

data: {"v":{"response":{"message_id":2,"role":"ASSISTANT","fragments":[{"id":2,"type":"THINK", ...}]}}}

data: {"p":"response/conversation_mode","v":"DEEP_SEARCH"}

data: {"p":"response/fragments/-1/content","o":"APPEND","v":"想知道"}

data: {"v":"云南"}
data: {"v":"最好"}
…

data: {"p":"response","o":"BATCH","v":[
  {"p":"fragments","o":"APPEND","v":[{"id":3,"type":"TOOL_SEARCH","queries":[...], "results":[]}]},
  {"p":"has_pending_fragment","o":"SET","v":false}
]}

data: {"p":"response/fragments/-1/results","o":"SET","v":[{...}]}

data: {"v":"最好玩的是什么..."}
…

data: {"p":"response","o":"BATCH","v":[
  {"p":"accumulated_token_usage","v":1898},
  {"p":"quasi_status","v":"FINISHED"}
]}

data: {"p":"response/status","o":"SET","v":"FINISHED"}

event: title
data: {"content":"云南最好玩推荐"}

event: close
data: {"click_behavior":"none","auto_resume":false}
```

Patch dialect:
- `{"v": "<text>"}` — bare append. Routes to whichever fragment is current. `THINK` fragments are reasoning; everything else is the visible response.
- `{"p": "<path>", "o": "SET" | "APPEND" | "BATCH", "v": <value>}` — JSON-Patch-style operation against the response object. Path uses `/` separators with `-1` meaning the last fragment.
- `{"p": "...", "o": "BATCH", "v": [<child patches>]}` — children's `p` fields are relative.
- Lines beginning with `:` are SSE keep-alive comments; ignore them.

Fragment types observed:
- `THINK` — reasoning trace (only when `thinking_enabled: true`).
- `TOOL_SEARCH` — search activity. Has `queries: [{"query": "..."}]` and later `results: [{"url","title","snippet","published_at","site_icon",...}]`.
- (Untyped / default) — assistant's visible markdown response.

`event: title` arrives once the server has auto-generated a session title. `event: close` terminates the stream — `auto_resume: false` means generation finished cleanly.

## Other endpoints worth knowing

These were not in the captured HAR but are visible in the JS bundle and useful for follow-up work:
- `POST /api/v0/chat_session/delete` `{ "chat_session_ids": [...] }`
- `POST /api/v0/chat_session/fetch_page` for listing sessions
- `POST /api/v0/chat/history_messages` for replaying a session's messages
- `POST /api/v0/file/upload_file` for the `ref_file_ids` flow

Reverse-engineer them on demand the same way (capture HAR, look at request shape, handle the standard envelope).
