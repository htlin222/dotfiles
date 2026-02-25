---
name: vm-docker
description: Use when deploying Docker services on the local VM (hostname: vm, Pop!_OS) with Traefik reverse proxy and Homepage dashboard. Covers crane image workflow, Traefik file-provider registration, Homepage services.yaml entries, and compose templates on the traefik-proxy network.
---

# Docker on VM with Traefik + Homepage

## Overview

Deploy Docker services on the VM (Pop!_OS). Web services go behind **Traefik** (port 80) and register on **Homepage** (dashboard at `/`).

- **Access domain**: `vm.local` (mDNS) — use for app `CMD_DOMAIN`/`BASE_URL`, NOT `vm`
- **Network**: `traefik-proxy` (external bridge) — all web containers must join
- **Crane**: `~/go/bin/crane` (NOT on PATH)
- **Compose**: `docker compose` (plugin at `~/.docker/cli-plugins/`). Must `cd` into service dir — `-f` flag broken

## Architecture

```
Port 80 → Traefik ──┬── /              → Homepage (dashboard)
                     ├── /hedgedoc      → HedgeDoc (:3000) [subpath-aware]
                     ├── /freshrss      → FreshRSS (:80)
                     ├── /traefik       → Traefik dashboard (api@internal)
                     └── /<service>     → Your new service

Direct ports ───────── :6060            → BookLore [no subpath support]

Config:  ~/traefik/traefik.yml          — static config
         ~/traefik/dynamic/<service>.yml — per-service routing
         ~/homepage/config/services.yaml — dashboard entries
```

## Deploy Checklist

1. **Prepare** — `mkdir -p ~/docker/<service>/{data,config}`
2. **Pull** — `~/go/bin/crane pull <image>:<tag> /tmp/<name>.tar`
3. **Load** — `docker load -i /tmp/<name>.tar`
4. **Compose** — Write `~/docker/<service>/docker-compose.yml` → `cd ~/docker/<service> && docker compose up -d`
5. **Traefik** — Create `~/traefik/dynamic/<service>.yml` (auto-reloads)
6. **Validate before writing configs** — curl-test EVERY URL/route before hardcoding into config files (see Validation section)
7. **Homepage** — Add entry to `~/homepage/config/services.yaml` + group in `settings.yaml`
8. **Verify** — `curl -sI --noproxy '*' http://localhost/<service>`

## Validation (MUST DO before writing configs)

**Always curl-test links before hardcoding them.** Do not assume a route works — prove it.

```bash
# 1. Test container responds directly (find internal IP or use exposed port)
curl -sI --noproxy '*' http://127.0.0.1:<host-port>/

# 2. Test Traefik route works (after writing dynamic config, before Homepage)
curl -sI --noproxy '*' http://127.0.0.1/<service>/

# 3. Test subpath: check HTML AND assets (not just the first response)
curl -s --noproxy '*' http://127.0.0.1/<service>/ | grep -E '<base href|<script src|<link.*href'
# If asset paths are absolute (e.g. /styles.css not ./<service>/styles.css) → subpath won't work

# 4. Test Homepage href URL resolves (the exact URL that will go in services.yaml)
curl -sI --noproxy '*' <href-value>

# 5. Test widget URLs (e.g. Traefik widget)
curl -s --noproxy '*' http://traefik:8080/api/overview
```

**Rule: If curl returns 404, 502, or broken assets → fix FIRST, then write the config.**

## Key Gotchas

| Gotcha | Detail |
|--------|--------|
| **Container name** | Use `http://<container>:<port>` in Traefik config, NOT localhost |
| **Sub-path + stripPrefix** | Need BOTH: `stripPrefix` in Traefik AND app's `BASE_URL`/`CMD_URL_PATH`. Test CSS/JS assets, not just HTML. **BUT** some SPAs (e.g. Booklore) don't support subpath at all — use direct port instead |
| **Subpath compatibility** | Before deploying behind subpath, check if the app supports it. SPAs with hardcoded `<base href="/">` and no `BASE_PATH` config will break. Use direct host port + Homepage `href: http://172.16.252.7:<port>` as fallback |
| **CMD_DOMAIN must match access IP** | For apps like HedgeDoc with `CMD_DOMAIN`, set it to the IP/hostname users actually use (e.g. `172.16.252.7`), NOT `vm.local` if users access via IP |
| **No host ports** | Don't expose ports if Traefik handles routing. Exception: apps without subpath support MUST expose host ports |
| **Traefik dashboard needs 2 routers** | Dashboard at `/traefik` uses `stripPrefix` + `api@internal`. But dashboard JS calls `/api/...` hardcoded — need a second router `PathPrefix(/api)` → `api@internal` (no strip). Without it, API calls fall through to Homepage and dashboard shows empty data. Do NOT use `api.basePath` — it breaks the insecure port API and the Homepage widget |
| **Priority 10** | Set on all routers so Homepage `/` catch-all still works |
| **Auth** | `auth@file` for BasicAuth — omit for public services |
| **Volume paths** | Always absolute: `/home/htlin222/docker/<service>/...` |

## Deep-Dive Docs

| Topic | File |
|-------|------|
| Templates (compose, traefik, homepage, makefile) | @templates.md |
| Troubleshooting | @troubleshooting.md |
| Reference stacks (ready-to-deploy) | `references/*.yml` |

## Homepage Groups

| Group | Current Services |
|-------|------------------|
| Media | Booklore (direct port :6060, no subpath support) |
| Productivity | HedgeDoc (subpath via Traefik, `CMD_DOMAIN=172.16.252.7`) |
| Infrastructure | Traefik |
