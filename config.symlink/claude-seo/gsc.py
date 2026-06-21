# /// script
# requires-python = ">=3.10"
# dependencies = ["google-auth>=2.0", "requests>=2.28"]
# ///
"""Minimal GSC Search Analytics CLI.

Usage (uv auto-installs deps, no venv needed):

    uv run ~/.config/claude-seo/gsc.py                       # last 28d, top pages
    uv run ~/.config/claude-seo/gsc.py --dimensions query    # top queries
    uv run ~/.config/claude-seo/gsc.py --quick-wins          # pos 4-10, high impressions
    uv run ~/.config/claude-seo/gsc.py --low-ctr             # high impressions, low CTR (實驗 1)
    uv run ~/.config/claude-seo/gsc.py --days 90 --json

Auth: service-account JSON. Resolved from, in order:
    1. $GOOGLE_APPLICATION_CREDENTIALS
    2. ~/.config/claude-seo/service_account.json
Property: --property, or $GSC_PROPERTY, default sc-domain:hsiehting.com
"""
import argparse
import datetime as dt
import json
import os
import sys
from pathlib import Path

from google.oauth2 import service_account
from google.auth.transport.requests import AuthorizedSession

SCOPE = "https://www.googleapis.com/auth/webmasters.readonly"
CONFIG_DIR = Path.home() / ".config" / "claude-seo"


def creds_path() -> Path:
    env = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
    if env:
        return Path(env).expanduser()
    return CONFIG_DIR / "service_account.json"


def default_property() -> str:
    return os.environ.get("GSC_PROPERTY", "sc-domain:hsiehting.com")


def query(prop, start, end, dimensions, row_limit, search_type):
    path = creds_path()
    if not path.exists():
        sys.exit(
            f"找不到 service account 金鑰: {path}\n"
            "→ 完成 GCP 設定後,把下載的 JSON 放到這裡(或設 $GOOGLE_APPLICATION_CREDENTIALS)。"
        )
    creds = service_account.Credentials.from_service_account_file(str(path), scopes=[SCOPE])
    session = AuthorizedSession(creds)
    url = (
        "https://searchconsole.googleapis.com/webmasters/v3/sites/"
        + requests_quote(prop)
        + "/searchAnalytics/query"
    )
    body = {
        "startDate": start,
        "endDate": end,
        "dimensions": dimensions,
        "rowLimit": row_limit,
        "type": search_type,
    }
    r = session.post(url, json=body, timeout=60)
    if r.status_code == 403:
        sa = creds.service_account_email
        sys.exit(
            f"403 Forbidden — service account 還沒被加進這個 property。\n"
            f"→ GSC > 設定 > 使用者和權限 > 新增使用者: {sa} (權限選「完整」)\n"
            f"   property = {prop}"
        )
    if r.status_code == 404:
        sys.exit(
            f"404 — property 格式或不存在: {prop}\n"
            "→ Domain property 用 sc-domain:hsiehting.com;URL-prefix 用 https://lin.hsiehting.com/ (含尾斜線)"
        )
    r.raise_for_status()
    return r.json().get("rows", [])


def requests_quote(s: str) -> str:
    from urllib.parse import quote
    return quote(s, safe="")


def main():
    ap = argparse.ArgumentParser(description="GSC Search Analytics CLI")
    ap.add_argument("--property", default=default_property())
    ap.add_argument("--days", type=int, default=28)
    ap.add_argument("--dimensions", default="page", help="逗號分隔: page,query,country,device,date")
    ap.add_argument("--limit", type=int, default=50)
    ap.add_argument("--type", default="web", choices=["web", "image", "video", "news", "discover"])
    ap.add_argument("--quick-wins", action="store_true", help="位置 4-10 且曝光高的 query")
    ap.add_argument("--low-ctr", action="store_true", help="曝光>200 且 CTR<2%% 的 page (實驗 1)")
    ap.add_argument("--json", action="store_true")
    args = ap.parse_args()

    # GSC 資料延遲 2-3 天,所以 end 抓 3 天前
    end = dt.date.today() - dt.timedelta(days=3)
    start = end - dt.timedelta(days=args.days)

    dims = ["query"] if args.quick_wins else (["page"] if args.low_ctr else args.dimensions.split(","))
    rows = query(args.property, start.isoformat(), end.isoformat(), dims, max(args.limit, 1000), args.type)

    def f(row):
        return {
            "keys": row.get("keys", []),
            "clicks": row.get("clicks", 0),
            "impressions": row.get("impressions", 0),
            "ctr": row.get("ctr", 0.0),
            "position": row.get("position", 0.0),
        }

    data = [f(r) for r in rows]

    if args.quick_wins:
        data = [d for d in data if 4 <= d["position"] <= 10 and d["impressions"] >= 50]
        data.sort(key=lambda d: d["impressions"], reverse=True)
    elif args.low_ctr:
        data = [d for d in data if d["impressions"] >= 200 and d["ctr"] < 0.02]
        data.sort(key=lambda d: d["impressions"], reverse=True)
    else:
        data.sort(key=lambda d: d["clicks"], reverse=True)
    data = data[: args.limit]

    if args.json:
        print(json.dumps({"property": args.property, "start": start.isoformat(),
                          "end": end.isoformat(), "rows": data}, ensure_ascii=False, indent=2))
        return

    print(f"# {args.property}  |  {start} → {end}  ({args.days}d)")
    label = "QUICK WINS (pos 4-10)" if args.quick_wins else ("LOW CTR (>200 imp, <2%)" if args.low_ctr else dims[0])
    print(f"# {label}  —  {len(data)} rows\n")
    print(f"{'clicks':>7} {'impr':>8} {'ctr':>7} {'pos':>6}  key")
    print("-" * 70)
    for d in data:
        key = " | ".join(d["keys"])
        print(f"{d['clicks']:>7.0f} {d['impressions']:>8.0f} {d['ctr']*100:>6.2f}% {d['position']:>6.1f}  {key}")


if __name__ == "__main__":
    main()
