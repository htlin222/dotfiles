"""Minimal DeepSeek webGUI client.

Reuses an authenticated session (cookies.json exported from the browser) to call
the same private API surface that chat.deepseek.com uses, and parses the SSE
stream into a clean structured timeline.

Endpoints (chat.deepseek.com)
- POST /api/v0/chat_session/create        -> {biz_data.chat_session.id}
- POST /api/v0/chat/create_pow_challenge  -> {biz_data.challenge}
- POST /api/v0/chat/completion            -> text/event-stream
"""
from __future__ import annotations

import base64
import json
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Iterator, Iterable

import httpx

from pow import solve_pow_challenge

BASE = "https://chat.deepseek.com"

DEFAULT_HEADERS = {
    "accept": "*/*",
    "accept-language": "zh-CN,zh;q=0.9,en;q=0.8",
    "content-type": "application/json",
    "origin": BASE,
    "referer": f"{BASE}/",
    "user-agent": (
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
        "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36"
    ),
    "x-app-version": "2.0.0",
    "x-client-locale": "en_US",
    "x-client-platform": "web",
    "x-client-version": "2.0.0",
    "x-client-timezone-offset": "28800",
}


def load_cookies(path: str | Path) -> dict[str, str]:
    """Load cookies in the {EditThisCookie / Cookie-Editor} JSON export format."""
    raw = json.loads(Path(path).read_text())
    jar: dict[str, str] = {}
    for c in raw:
        if "deepseek.com" not in c["domain"]:
            continue
        jar[c["name"]] = c["value"]
    return jar


def load_auth_token(path: str | Path | None) -> str | None:
    """Resolve an auth token from (1) DEEPSEEK_TOKEN env var, (2) auth.json file
    with shape {"token": "..."}, (3) cookies.json sibling auth.json.

    chat.deepseek.com sends `Authorization: Bearer <token>` where the token is
    the value of `localStorage.userToken` in the browser. To export it:
    DevTools → Application → Local Storage → https://chat.deepseek.com →
    copy the `userToken` value.
    """
    import os
    tok = os.environ.get("DEEPSEEK_TOKEN")
    if tok:
        return tok.strip()
    if path is None:
        return None
    p = Path(path)
    if p.exists():
        data = json.loads(p.read_text())
        if isinstance(data, dict):
            # Accept the localStorage wrapper shape directly:
            # {"value": "<token>", "__version": "0"}
            if "value" in data and isinstance(data["value"], str):
                return data["value"]
            return data.get("token") or data.get("userToken")
        if isinstance(data, str):
            return data.strip()
    return None


@dataclass
class StreamEvent:
    kind: str            # "ready" | "delta" | "think_delta" | "tool_search" | "search_results" | "title" | "close" | "raw"
    data: dict = field(default_factory=dict)
    text: str = ""


class DeepSeekClient:
    def __init__(
        self,
        cookies: dict[str, str],
        *,
        token: str | None = None,
        timeout: float = 60.0,
    ):
        self.cookies = cookies
        self.token = token
        headers = dict(DEFAULT_HEADERS)
        if token:
            headers["authorization"] = f"Bearer {token}"
        self._client = httpx.Client(
            base_url=BASE,
            cookies=cookies,
            headers=headers,
            timeout=httpx.Timeout(timeout, read=None),
        )

    def close(self) -> None:
        self._client.close()

    def __enter__(self):
        return self

    def __exit__(self, *exc):
        self.close()

    # ---- low-level API wrappers --------------------------------------------------

    def create_session(self) -> str:
        r = self._client.post("/api/v0/chat_session/create", json={})
        r.raise_for_status()
        body = r.json()
        if body.get("code") != 0:
            raise RuntimeError(f"create_session failed: {body}")
        return body["data"]["biz_data"]["chat_session"]["id"]

    def create_pow_challenge(self, target_path: str = "/api/v0/chat/completion") -> dict:
        r = self._client.post(
            "/api/v0/chat/create_pow_challenge",
            json={"target_path": target_path},
        )
        r.raise_for_status()
        body = r.json()
        if body.get("code") != 0:
            raise RuntimeError(f"create_pow_challenge failed: {body}")
        return body["data"]["biz_data"]["challenge"]

    def _pow_header(self, challenge: dict) -> str:
        solved = solve_pow_challenge(
            algorithm=challenge["algorithm"],
            challenge=challenge["challenge"],
            salt=challenge["salt"],
            expire_at=challenge["expire_at"],
            difficulty=challenge["difficulty"],
            signature=challenge["signature"],
            target_path=challenge["target_path"],
        )
        return base64.b64encode(json.dumps(solved, separators=(",", ":")).encode()).decode()

    def completion(
        self,
        prompt: str,
        *,
        chat_session_id: str | None = None,
        parent_message_id: int | None = None,
        thinking: bool = False,
        search: bool = False,
        model_type: str = "default",     # "default" or "expert" (DeepSeek-V3 vs reasoning)
        ref_file_ids: Iterable[str] | None = None,
    ) -> Iterator[StreamEvent]:
        """Stream a completion, yielding parsed StreamEvent objects."""
        if chat_session_id is None:
            chat_session_id = self.create_session()
        challenge = self.create_pow_challenge()
        pow_token = self._pow_header(challenge)

        body = {
            "chat_session_id": chat_session_id,
            "parent_message_id": parent_message_id,
            "model_type": model_type,
            "prompt": prompt,
            "ref_file_ids": list(ref_file_ids or []),
            "thinking_enabled": thinking,
            "search_enabled": search,
            "preempt": False,
        }
        with self._client.stream(
            "POST",
            "/api/v0/chat/completion",
            json=body,
            headers={"x-ds-pow-response": pow_token, "accept": "text/event-stream"},
        ) as r:
            r.raise_for_status()
            yield from _parse_sse(r.iter_lines())


def _parse_sse(lines: Iterable[str]) -> Iterator[StreamEvent]:
    """Parse the SSE stream into structured events.

    The server speaks a JSON-Patch dialect. We collapse the chatter most
    callers care about (text deltas, thinking deltas, search activity, title,
    close) and forward everything else as a `raw` event. The parser tracks
    the currently-active fragment type (THINK / TOOL_SEARCH / regular text)
    so that subsequent bare `{"v": "..."}` deltas are routed correctly.
    """
    event_name = None
    data_lines: list[str] = []
    state: dict = {"current_fragment_type": None}

    def flush() -> Iterator[StreamEvent]:
        nonlocal event_name, data_lines
        if not data_lines:
            event_name = None
            return
        raw = "\n".join(data_lines).strip()
        data_lines = []
        ev = event_name
        event_name = None
        if not raw:
            return
        try:
            payload = json.loads(raw)
        except Exception:
            yield StreamEvent("raw", {}, text=raw)
            return

        if ev == "ready":
            yield StreamEvent("ready", payload)
            return
        if ev == "title":
            yield StreamEvent("title", payload, text=payload.get("content", ""))
            return
        if ev == "close":
            yield StreamEvent("close", payload)
            return
        if ev == "update_session":
            return  # noisy, drop

        yield from _interpret_patch(payload, state)

    for line in lines:
        if line == "" or line is None:
            yield from flush()
            continue
        if line.startswith(":"):
            continue
        if line.startswith("event:"):
            event_name = line[6:].strip()
            continue
        if line.startswith("data:"):
            data_lines.append(line[5:].lstrip())
            continue
    yield from flush()


def _walk_fragments(v) -> Iterator[dict]:
    """Yield every fragment object (any `type`) found in a nested response payload."""
    if isinstance(v, dict):
        if "type" in v and ("content" in v or v.get("type") in ("THINK", "TOOL_SEARCH", "RESPONSE")):
            yield v
        for child in v.values():
            if isinstance(child, (dict, list)):
                yield from _walk_fragments(child)
    elif isinstance(v, list):
        for child in v:
            yield from _walk_fragments(child)


def _interpret_patch(payload: dict, state: dict) -> Iterator[StreamEvent]:
    """Translate a single JSON-Patch frame into one or more StreamEvents."""
    # Bare {"v": "..."} = APPEND to currently-active fragment
    if set(payload.keys()) == {"v"} and isinstance(payload["v"], str):
        ftype = state.get("current_fragment_type")
        kind = "think_delta" if ftype == "THINK" else "delta"
        yield StreamEvent(kind, payload, text=payload["v"])
        return

    if set(payload.keys()) == {"v"} and isinstance(payload["v"], dict):
        emitted = False
        for frag in _walk_fragments(payload["v"]):
            state["current_fragment_type"] = frag.get("type")
            content = frag.get("content")
            if isinstance(content, str) and content:
                kind = "think_delta" if frag.get("type") == "THINK" else "delta"
                yield StreamEvent(kind, {"v": content}, text=content)
                emitted = True
        if not emitted:
            yield StreamEvent("raw", payload)
        return

    p = payload.get("p")
    op = payload.get("o", "SET")
    v = payload.get("v")

    if p is None:
        yield StreamEvent("raw", payload)
        return

    if op == "BATCH" and isinstance(v, list):
        for child in v:
            base = child.get("p", "")
            child = {**child, "p": f"{p}/{base}".rstrip("/")}
            yield from _interpret_patch(child, state)
        return

    if p.endswith("/fragments") and op == "APPEND" and isinstance(v, list):
        emitted = False
        for frag in v:
            state["current_fragment_type"] = frag.get("type")
            content = frag.get("content")
            if isinstance(content, str) and content:
                kind = "think_delta" if frag.get("type") == "THINK" else "delta"
                yield StreamEvent(kind, {"v": content}, text=content)
                emitted = True
        if not emitted:
            yield StreamEvent("raw", payload)
        return

    if p.endswith("/content") and op == "APPEND":
        ftype = state.get("current_fragment_type")
        kind = "think_delta" if ftype == "THINK" else "delta"
        yield StreamEvent(kind, payload, text=v if isinstance(v, str) else "")
        return

    if p.endswith("/queries") and op in ("SET", "APPEND"):
        yield StreamEvent("tool_search", payload)
        return
    if p.endswith("/results") and op in ("SET", "APPEND"):
        yield StreamEvent("search_results", payload)
        return

    yield StreamEvent("raw", payload)


# ---- CLI -----------------------------------------------------------------------

def main(argv: list[str]) -> int:
    import argparse
    ap = argparse.ArgumentParser(description="Send a prompt to the DeepSeek webGUI.")
    ap.add_argument("prompt", help="Prompt text")
    ap.add_argument("--cookies", default="cookies.json", help="Path to cookies JSON export")
    ap.add_argument("--auth", default="auth.json", help="Path to auth.json with {\"token\": \"...\"}")
    ap.add_argument("--thinking", action="store_true", help="Enable reasoning trace")
    ap.add_argument("--search", action="store_true", help="Enable web search")
    ap.add_argument("--model", default="default", choices=["default", "expert"])
    ap.add_argument("--session", help="Reuse an existing chat_session_id (else create new)")
    ap.add_argument("--raw", action="store_true", help="Print every parsed event as JSON")
    args = ap.parse_args(argv)

    cookies = load_cookies(args.cookies)
    token = load_auth_token(args.auth)
    with DeepSeekClient(cookies, token=token) as ds:
        sid = args.session or ds.create_session()
        for ev in ds.completion(
            args.prompt,
            chat_session_id=sid,
            thinking=args.thinking,
            search=args.search,
            model_type=args.model,
        ):
            if args.raw:
                print(json.dumps({"kind": ev.kind, "data": ev.data, "text": ev.text}, ensure_ascii=False))
                continue
            if ev.kind == "delta":
                print(ev.text, end="", flush=True)
            elif ev.kind == "title":
                print(f"\n\n--- title: {ev.text}")
            elif ev.kind == "close":
                print()
                break
        return 0


if __name__ == "__main__":
    import sys
    raise SystemExit(main(sys.argv[1:]))
