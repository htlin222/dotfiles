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
                     ├── /booklore      → BookLore (:6060)
                     ├── /hedgedoc      → HedgeDoc (:3000)
                     ├── /freshrss      → FreshRSS (:80)
                     ├── /traefik       → Traefik dashboard (api@internal)
                     └── /<service>     → Your new service

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
6. **Homepage** — Add entry to `~/homepage/config/services.yaml` + group in `settings.yaml`
7. **Verify** — `curl -sI --noproxy '*' http://localhost/<service>`

## Key Gotchas

| Gotcha | Detail |
|--------|--------|
| **Container name** | Use `http://<container>:<port>` in Traefik config, NOT localhost |
| **Sub-path + stripPrefix** | Almost always need BOTH: `stripPrefix` in Traefik AND app's `BASE_URL`/`CMD_URL_PATH`. The app env var only affects link generation, NOT route mounting. Test CSS/JS assets, not just HTML |
| **No host ports** | Don't expose ports if Traefik handles routing |
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
| Media | Booklore |
| Productivity | HedgeDoc |
| Infrastructure | Traefik |
