---
name: deepseek-webgui
description: Talk to DeepSeek through its private chat.deepseek.com API (the same one the web UI uses) with a browser-exported `userToken`, instead of the official platform.deepseek.com OpenAI-compatible API. Use when the user wants to drive their personal/free DeepSeek webgui account from a script or TUI, mentions reusing browser cookies, asks about the `x-ds-pow-response` POW header, the `DeepSeekHashV1` algorithm, the SSE streaming format with `THINK` / `TOOL_SEARCH` fragments, or wants to integrate the webgui backend into another tool (e.g. DeepSeek-TUI). Bundles a SHA3 WASM POW solver run via `wasmtime`, an httpx-based client, and an SSE patch-stream parser.
---

# deepseek-webgui

## Overview

Drives the **private** API behind `chat.deepseek.com` — the same one the React frontend calls. Useful when the user wants to use their existing webgui account (free quotas, browser-based reasoning + search) from a script, TUI, or another tool, and does not want to (or cannot) move to the paid OpenAI-compatible API at `platform.deepseek.com`.

The hard part is the proof-of-work: every `/api/v0/chat/completion` call requires an `x-ds-pow-response` header containing a base64-encoded answer to a server-issued `DeepSeekHashV1` challenge. The algorithm is implemented as an SHA3-based WASM solver inside the frontend bundle. This skill ships that WASM and drives it from Python via `wasmtime` so no Node.js is required at runtime.

## When to use this skill

Reach for it when any of the following appears:

- "use my deepseek web account / cookies / session", "free deepseek", "no API key"
- "deepseek-tui", "deepseek4free", "wrap chat.deepseek.com"
- "x-ds-pow-response", "DeepSeekHashV1", "POW challenge", "create_pow_challenge"
- "parse deepseek SSE", "THINK fragment", "TOOL_SEARCH", "JSON-Patch deepseek"

Prefer the **official** OpenAI-compatible API at `https://api.deepseek.com` whenever the user has (or can get) a paid API key. It is faster, supported, and has no anti-bot. This skill exists for the case where that is not an option.

## Quick start

```bash
# 1) Capture credentials from the browser (one-time)
#    a. Log into https://chat.deepseek.com in any browser.
#    b. DevTools console:  copy(localStorage.userToken)            # paste into auth.json
#    c. Cookie-Editor / EditThisCookie: export *.deepseek.com      # save as cookies.json

# 2) Place credentials next to the prompt or anywhere convenient:
echo '{"token": "<paste userToken here>"}' > auth.json

# 3) Send a prompt.
scripts/run.sh "Summarise the difference between TLS 1.2 and 1.3 in 3 bullets."

# Flags:
#   --thinking           enable reasoning trace (THINK fragments → think_delta events)
#   --search             enable web search (TOOL_SEARCH fragment → tool_search events)
#   --model expert       use the reasoning model (default: "default" = DeepSeek-V3)
#   --raw                emit every parsed StreamEvent as JSON (machine-readable mode)
#   --cookies/--auth     override file paths
```

`run.sh` is a thin `uv run --with wasmtime --with httpx` wrapper. If `uv` is unavailable, `pip install httpx wasmtime` and run `python3 scripts/client.py` directly.

## Architecture

```
prompt
  │
  ▼
DeepSeekClient.completion()
  │
  ├─ 1. POST /api/v0/chat_session/create        →  chat_session.id
  ├─ 2. POST /api/v0/chat/create_pow_challenge  →  challenge {algorithm, challenge, salt, expire_at, difficulty, signature}
  ├─ 3. solve_pow_challenge(...)                →  answer (int)            (scripts/pow.py + sha3.wasm)
  │      base64(JSON(answer + challenge + ...))→  x-ds-pow-response
  │
  └─ 4. POST /api/v0/chat/completion (streaming SSE)
           │
           └─ _parse_sse(...)  →  StreamEvent("delta"|"think_delta"|"tool_search"|"search_results"|"title"|"close"|"raw"|"ready")
```

Three layers of credentials are required and the API will reject calls missing any one of them:
- `Authorization: Bearer <userToken>` from `localStorage.userToken`.
- Cookies on `*.deepseek.com` (`aws-waf-token` for WAF + `ds_session_id` for session).
- A handful of frontend identity headers (`x-app-version`, `x-client-platform`, etc.) — the client sets them automatically.

If a request returns `{"code":40002,"msg":"Missing Token"}` the userToken is missing or expired. If the response is a 202 with `x-amzn-waf-action: challenge`, the `aws-waf-token` cookie has expired — the user needs to refresh `chat.deepseek.com` in the browser and re-export cookies.

## Files

- `scripts/client.py` — `DeepSeekClient`, SSE parser, CLI. Public surface:
  - `load_cookies(path) -> dict[str,str]` — parses Cookie-Editor / EditThisCookie JSON.
  - `load_auth_token(path) -> str | None` — reads `DEEPSEEK_TOKEN` env var or `{"token": "..."}` file.
  - `DeepSeekClient(cookies, token=...).completion(prompt, *, thinking, search, model_type, chat_session_id, parent_message_id) -> Iterator[StreamEvent]`.
  - `StreamEvent.kind`: `"ready" | "delta" | "think_delta" | "tool_search" | "search_results" | "title" | "close" | "raw"`. The `text` field on `delta` / `think_delta` / `title` is the human-visible string to print or accumulate.
- `scripts/pow.py` — `solve_pow_challenge(...)`. Pure-Python wrapper around the bundled WASM via `wasmtime`. Includes a self-test against the captured HAR challenge that asserts answer == 49586.
- `scripts/sha3.wasm` — the unmodified `sha3_wasm_bg.wasm` from `fe-static.deepseek.com/chat/static/`. ~26 KB. Contains `wasm_solve` which is the iteration kernel.
- `scripts/run.sh` — `uv`-driven launcher.
- `references/api_reference.md` — full reverse-engineered API surface: endpoints, error codes, POW field semantics, SSE patch dialect with examples. Read this when extending the client (file uploads, history listing, session deletion).

## Embedding the client into another tool

To wire this into a TUI or another agent:

```python
from scripts.client import DeepSeekClient, load_cookies, load_auth_token, StreamEvent

cookies = load_cookies("cookies.json")
token   = load_auth_token("auth.json")

with DeepSeekClient(cookies, token=token) as ds:
    sid = ds.create_session()
    full = []
    for ev in ds.completion("Hello", chat_session_id=sid, thinking=True):
        if ev.kind == "delta":
            print(ev.text, end="", flush=True)
            full.append(ev.text)
        elif ev.kind == "think_delta":
            ...  # render in a side panel
        elif ev.kind == "close":
            break
    print("".join(full))
```

`completion()` is a generator — it yields events as bytes arrive over the SSE stream. The first call after `create_session()` is the slowest because it triggers a fresh POW challenge (~tens of milliseconds in the WASM solver, plus one extra round-trip).

## Known caveats

- **Token mortality**: the `userToken` is long-lived but not eternal. When DeepSeek invalidates it (logout, password change, server-side revoke) the user has to re-export it.
- **POW expiry**: each challenge is valid for `expire_after` ms (5 minutes in the captures). The client always solves a fresh one per `completion()` call, so this only matters if you cache challenges yourself.
- **Rate limits / banning**: this is a personal account talking to a private API. Hammering it will get the account flagged. Don't.
- **Schema drift**: the SSE patch dialect is internal and may change between commits of the chat frontend. The parser falls through to `raw` events for anything it doesn't recognise — log those if a previously-working stream starts producing unexpected output.

## Verification

The skill was built against a HAR capture of two real `chat/completion` round-trips. Verified:
- `solve_pow_challenge(...)` reproduces the captured `answer = 49586` from `(challenge, salt, expire_at, difficulty)`.
- `_parse_sse(...)` consumes the captured 123 KB SSE stream and yields the expected fragment partitioning (162 chars of THINK reasoning + 3569 chars of visible response + the `云南最好玩推荐` title).

End-to-end live verification requires the user's `userToken`. Without it the API responds `{"code":40002,"msg":"Missing Token"}` immediately — there is no anonymous mode or cookie-only fallback (verified directly).
