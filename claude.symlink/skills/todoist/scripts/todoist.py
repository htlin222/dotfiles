#!/usr/bin/env python3
"""Todoist API v1 CLI — CRUD for tasks, projects, sections, labels, comments.

Token source (in order):
  1. TODOIST_API_TOKEN environment variable
  2. <skill_dir>/.apikey
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

API_BASE = "https://api.todoist.com/api/v1"
SKILL_DIR = Path(__file__).resolve().parent.parent


def load_token() -> str:
    token = os.environ.get("TODOIST_API_TOKEN", "").strip()
    if token:
        return token
    key_file = SKILL_DIR / ".apikey"
    if key_file.exists():
        t = key_file.read_text().strip()
        if t:
            return t
    sys.exit(
        "error: Todoist token not found. Set TODOIST_API_TOKEN env var or write "
        f"token to {key_file}"
    )


def api(method: str, path: str, params: dict | None = None, body: dict | None = None):
    url = f"{API_BASE}{path}"
    if params:
        cleaned = {k: v for k, v in params.items() if v is not None}
        if cleaned:
            url += "?" + urllib.parse.urlencode(cleaned, doseq=True)
    data = None
    if body is not None:
        cleaned_body = {k: v for k, v in body.items() if v is not None}
        data = json.dumps(cleaned_body).encode("utf-8")
    headers = {
        "Authorization": f"Bearer {load_token()}",
        "Content-Type": "application/json",
    }
    req = urllib.request.Request(url, data=data, method=method, headers=headers)
    try:
        with urllib.request.urlopen(req) as resp:
            raw = resp.read()
            if not raw:
                return None
            return json.loads(raw.decode("utf-8"))
    except urllib.error.HTTPError as e:
        body_text = e.read().decode("utf-8", errors="replace")
        sys.exit(f"HTTP {e.code} {e.reason}: {body_text}")
    except urllib.error.URLError as e:
        sys.exit(f"network error: {e.reason}")


def out(obj) -> None:
    if obj is None:
        return
    print(json.dumps(obj, indent=2, ensure_ascii=False))
    # Todoist soft-deletes: GET on a deleted resource returns 200 with is_deleted=true.
    # Surface this clearly so callers don't mistake a tombstone for a live record.
    if isinstance(obj, dict) and obj.get("is_deleted") is True:
        print(
            f"warning: resource id={obj.get('id')} is soft-deleted (is_deleted=true)",
            file=sys.stderr,
        )
        sys.exit(2)


def split_csv(value: str | None) -> list[str] | None:
    if value is None:
        return None
    return [item.strip() for item in value.split(",") if item.strip()]


# ---------- Tasks ----------
def tasks_list(a):
    out(api("GET", "/tasks", params={
        "project_id": a.project_id,
        "section_id": a.section_id,
        "label": a.label,
        "filter": a.filter,
        "lang": a.lang,
        "ids": a.ids,
    }))


def tasks_get(a):
    out(api("GET", f"/tasks/{a.id}"))


def tasks_add(a):
    out(api("POST", "/tasks", body={
        "content": a.content,
        "description": a.description,
        "project_id": a.project_id,
        "section_id": a.section_id,
        "parent_id": a.parent_id,
        "priority": a.priority,
        "due_string": a.due,
        "due_date": a.due_date,
        "due_lang": a.due_lang,
        "labels": split_csv(a.labels),
        "duration": a.duration,
        "duration_unit": a.duration_unit,
    }))


def tasks_update(a):
    out(api("POST", f"/tasks/{a.id}", body={
        "content": a.content,
        "description": a.description,
        "priority": a.priority,
        "due_string": a.due,
        "due_date": a.due_date,
        "due_lang": a.due_lang,
        "labels": split_csv(a.labels),
        "duration": a.duration,
        "duration_unit": a.duration_unit,
    }))


def tasks_close(a):
    api("POST", f"/tasks/{a.id}/close")
    print(f"closed task {a.id}")


def tasks_reopen(a):
    api("POST", f"/tasks/{a.id}/reopen")
    print(f"reopened task {a.id}")


def tasks_delete(a):
    api("DELETE", f"/tasks/{a.id}")
    print(f"deleted task {a.id}")


# ---------- Projects ----------
def projects_list(_a):
    out(api("GET", "/projects"))


def projects_get(a):
    out(api("GET", f"/projects/{a.id}"))


def projects_add(a):
    out(api("POST", "/projects", body={
        "name": a.name,
        "parent_id": a.parent_id,
        "color": a.color,
        "is_favorite": a.favorite,
        "view_style": a.view_style,
    }))


def projects_update(a):
    out(api("POST", f"/projects/{a.id}", body={
        "name": a.name,
        "color": a.color,
        "is_favorite": a.favorite,
        "view_style": a.view_style,
    }))


def projects_delete(a):
    api("DELETE", f"/projects/{a.id}")
    print(f"deleted project {a.id}")


def projects_archive(a):
    api("POST", f"/projects/{a.id}/archive")
    print(f"archived project {a.id}")


def projects_unarchive(a):
    api("POST", f"/projects/{a.id}/unarchive")
    print(f"unarchived project {a.id}")


# ---------- Sections ----------
def sections_list(a):
    out(api("GET", "/sections", params={"project_id": a.project_id}))


def sections_get(a):
    out(api("GET", f"/sections/{a.id}"))


def sections_add(a):
    out(api("POST", "/sections", body={
        "name": a.name,
        "project_id": a.project_id,
        "order": a.order,
    }))


def sections_update(a):
    out(api("POST", f"/sections/{a.id}", body={"name": a.name}))


def sections_delete(a):
    api("DELETE", f"/sections/{a.id}")
    print(f"deleted section {a.id}")


# ---------- Labels ----------
def labels_list(_a):
    out(api("GET", "/labels"))


def labels_get(a):
    out(api("GET", f"/labels/{a.id}"))


def labels_add(a):
    out(api("POST", "/labels", body={
        "name": a.name,
        "color": a.color,
        "order": a.order,
        "is_favorite": a.favorite,
    }))


def labels_update(a):
    out(api("POST", f"/labels/{a.id}", body={
        "name": a.name,
        "color": a.color,
        "order": a.order,
        "is_favorite": a.favorite,
    }))


def labels_delete(a):
    api("DELETE", f"/labels/{a.id}")
    print(f"deleted label {a.id}")


# ---------- Comments ----------
def comments_list(a):
    if not (a.task_id or a.project_id):
        sys.exit("error: --task-id or --project-id required")
    out(api("GET", "/comments", params={
        "task_id": a.task_id,
        "project_id": a.project_id,
    }))


def comments_get(a):
    out(api("GET", f"/comments/{a.id}"))


def comments_add(a):
    if not (a.task_id or a.project_id):
        sys.exit("error: --task-id or --project-id required")
    out(api("POST", "/comments", body={
        "content": a.content,
        "task_id": a.task_id,
        "project_id": a.project_id,
    }))


def comments_update(a):
    out(api("POST", f"/comments/{a.id}", body={"content": a.content}))


def comments_delete(a):
    api("DELETE", f"/comments/{a.id}")
    print(f"deleted comment {a.id}")


# ---------- CLI plumbing ----------
def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(prog="todoist", description="Todoist API v1 CLI")
    sub = p.add_subparsers(dest="resource", required=True)

    # tasks
    t = sub.add_parser("tasks").add_subparsers(dest="action", required=True)
    tl = t.add_parser("list"); tl.add_argument("--project-id"); tl.add_argument("--section-id"); tl.add_argument("--label"); tl.add_argument("--filter"); tl.add_argument("--lang"); tl.add_argument("--ids"); tl.set_defaults(func=tasks_list)
    tg = t.add_parser("get"); tg.add_argument("id"); tg.set_defaults(func=tasks_get)
    ta = t.add_parser("add"); ta.add_argument("content"); ta.add_argument("--description"); ta.add_argument("--project-id"); ta.add_argument("--section-id"); ta.add_argument("--parent-id"); ta.add_argument("--priority", type=int, choices=[1,2,3,4]); ta.add_argument("--due"); ta.add_argument("--due-date"); ta.add_argument("--due-lang"); ta.add_argument("--labels", help="comma-separated"); ta.add_argument("--duration", type=int); ta.add_argument("--duration-unit", choices=["minute","day"]); ta.set_defaults(func=tasks_add)
    tu = t.add_parser("update"); tu.add_argument("id"); tu.add_argument("--content"); tu.add_argument("--description"); tu.add_argument("--priority", type=int, choices=[1,2,3,4]); tu.add_argument("--due"); tu.add_argument("--due-date"); tu.add_argument("--due-lang"); tu.add_argument("--labels"); tu.add_argument("--duration", type=int); tu.add_argument("--duration-unit", choices=["minute","day"]); tu.set_defaults(func=tasks_update)
    tc = t.add_parser("close"); tc.add_argument("id"); tc.set_defaults(func=tasks_close)
    tr = t.add_parser("reopen"); tr.add_argument("id"); tr.set_defaults(func=tasks_reopen)
    td = t.add_parser("delete"); td.add_argument("id"); td.set_defaults(func=tasks_delete)

    # projects
    pr = sub.add_parser("projects").add_subparsers(dest="action", required=True)
    pr.add_parser("list").set_defaults(func=projects_list)
    pg = pr.add_parser("get"); pg.add_argument("id"); pg.set_defaults(func=projects_get)
    pa = pr.add_parser("add"); pa.add_argument("name"); pa.add_argument("--parent-id"); pa.add_argument("--color"); pa.add_argument("--favorite", action="store_true", default=None); pa.add_argument("--view-style", choices=["list","board"]); pa.set_defaults(func=projects_add)
    pu = pr.add_parser("update"); pu.add_argument("id"); pu.add_argument("--name"); pu.add_argument("--color"); pu.add_argument("--favorite", action="store_true", default=None); pu.add_argument("--view-style", choices=["list","board"]); pu.set_defaults(func=projects_update)
    pd = pr.add_parser("delete"); pd.add_argument("id"); pd.set_defaults(func=projects_delete)
    par = pr.add_parser("archive"); par.add_argument("id"); par.set_defaults(func=projects_archive)
    pun = pr.add_parser("unarchive"); pun.add_argument("id"); pun.set_defaults(func=projects_unarchive)

    # sections
    sc = sub.add_parser("sections").add_subparsers(dest="action", required=True)
    sl = sc.add_parser("list"); sl.add_argument("--project-id"); sl.set_defaults(func=sections_list)
    sg = sc.add_parser("get"); sg.add_argument("id"); sg.set_defaults(func=sections_get)
    sa = sc.add_parser("add"); sa.add_argument("name"); sa.add_argument("--project-id", required=True); sa.add_argument("--order", type=int); sa.set_defaults(func=sections_add)
    su = sc.add_parser("update"); su.add_argument("id"); su.add_argument("--name", required=True); su.set_defaults(func=sections_update)
    sd = sc.add_parser("delete"); sd.add_argument("id"); sd.set_defaults(func=sections_delete)

    # labels
    lb = sub.add_parser("labels").add_subparsers(dest="action", required=True)
    lb.add_parser("list").set_defaults(func=labels_list)
    lg = lb.add_parser("get"); lg.add_argument("id"); lg.set_defaults(func=labels_get)
    la = lb.add_parser("add"); la.add_argument("name"); la.add_argument("--color"); la.add_argument("--order", type=int); la.add_argument("--favorite", action="store_true", default=None); la.set_defaults(func=labels_add)
    lu = lb.add_parser("update"); lu.add_argument("id"); lu.add_argument("--name"); lu.add_argument("--color"); lu.add_argument("--order", type=int); lu.add_argument("--favorite", action="store_true", default=None); lu.set_defaults(func=labels_update)
    ld = lb.add_parser("delete"); ld.add_argument("id"); ld.set_defaults(func=labels_delete)

    # comments
    cm = sub.add_parser("comments").add_subparsers(dest="action", required=True)
    cl = cm.add_parser("list"); cl.add_argument("--task-id"); cl.add_argument("--project-id"); cl.set_defaults(func=comments_list)
    cg = cm.add_parser("get"); cg.add_argument("id"); cg.set_defaults(func=comments_get)
    ca = cm.add_parser("add"); ca.add_argument("content"); ca.add_argument("--task-id"); ca.add_argument("--project-id"); ca.set_defaults(func=comments_add)
    cu = cm.add_parser("update"); cu.add_argument("id"); cu.add_argument("--content", required=True); cu.set_defaults(func=comments_update)
    cd = cm.add_parser("delete"); cd.add_argument("id"); cd.set_defaults(func=comments_delete)

    return p


def main():
    args = build_parser().parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
