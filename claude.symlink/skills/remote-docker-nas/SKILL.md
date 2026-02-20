---
name: remote-docker-nas
description: Use when running Docker containers on a remote NAS or server via SSH without a local Docker daemon, when the remote host cannot pull images from Docker Hub, or when setting up a lightweight laptop-to-NAS Docker workflow with crane.
---

# Remote Docker on NAS

## Overview

Run Docker on a remote NAS/server controlled from your laptop via SSH — **no local Docker daemon needed**. Uses `crane` (~11MB) to pull images as tarballs and `DOCKER_HOST=ssh://` to send commands to the remote daemon.

## Architecture

```
Laptop (control plane)                NAS/Server (execution)
──────────────────────                ────────────────────────
docker-compose.yml (local)            Docker daemon
Makefile (local)              ──SSH──▶ Containers run here
source code (local)                   Data stored here
crane pull → .tar (local)             docker load → images here
```

## Prerequisites

**Laptop:**
- `crane` — lightweight image puller, no daemon needed
  ```bash
  brew install crane
  ```
- `docker` CLI only (no Docker Desktop / OrbStack needed)
- SSH access to NAS (`~/.ssh/config` configured)

**NAS/Server:**
- Docker daemon running
- Your user in the `docker` group
  ```bash
  sudo usermod -aG docker <nas-user>
  # Log out and back in for group to take effect
  # Verify: groups | grep docker
  ```

## Setup

Set `DOCKER_HOST` to route all docker commands via SSH:

```bash
export DOCKER_HOST=ssh://<nas-host>

# Verify
docker info
```

Add to shell profile for persistence:
```bash
# ~/.zshrc or ~/.bashrc
export DOCKER_HOST=ssh://<nas-host>
```

## Image Workflow

When the NAS cannot reach Docker Hub (firewall/network), pull images on the laptop with `crane` and load them onto the NAS:

```bash
# 1. Pull image as tarball (runs on laptop, no daemon needed)
crane pull nginx:alpine /tmp/nginx-alpine.tar

# 2. Load onto NAS (DOCKER_HOST routes this via SSH)
docker load -i /tmp/nginx-alpine.tar

# 3. Run
docker run -d --name web -p 8080:80 nginx:alpine
```

## Key Gotchas

| Aspect | Behavior |
|--------|----------|
| **Compose file** | Read from **laptop** (local path) |
| **Volume paths** | Mounted from **NAS filesystem** (must be absolute NAS paths) |
| **Source files** | Must be **copied to NAS** via `scp` before compose up |
| **Port binding** | Ports bind on **NAS IP**, access via `http://<nas-ip>:<port>` |

**The #1 mistake:** Using relative volume paths like `./html:/usr/share/nginx/html`. This resolves on the NAS, not your laptop. Use absolute NAS paths.

## Docker Compose Template

```yaml
services:
  web:
    image: nginx:alpine
    ports:
      - "8888:80"
    volumes:
      - /home/<nas-user>/project/html:/usr/share/nginx/html:ro
    restart: unless-stopped
```

**Deploy workflow:**
```bash
# 1. Copy source files to NAS
scp -r ./html <nas-host>:/home/<nas-user>/project/

# 2. Pull and load images
crane pull nginx:alpine /tmp/nginx-alpine.tar
docker load -i /tmp/nginx-alpine.tar

# 3. Start (compose file is local, execution is remote)
docker compose up -d
```

## Makefile Template

```makefile
DOCKER_HOST := ssh://<nas-host>
NAS_PROJECT := /home/<nas-user>/project
export DOCKER_HOST

IMAGES := nginx:alpine

.PHONY: pull load sync up down ps logs clean

pull:
	@for img in $(IMAGES); do \
		echo "Pulling $$img..."; \
		crane pull $$img /tmp/$$(echo $$img | tr '/:' '-').tar; \
	done

load:
	@for img in $(IMAGES); do \
		tarfile=/tmp/$$(echo $$img | tr '/:' '-').tar; \
		echo "Loading $$tarfile..."; \
		docker load -i $$tarfile; \
	done

sync:
	scp -r ./html <nas-host>:$(NAS_PROJECT)/

up: pull load sync
	docker compose up -d

down:
	docker compose down

ps:
	docker compose ps

logs:
	docker compose logs -f

clean: down
	docker compose rm -f
	docker image prune -f
```

## Reference Stacks

Ready-to-deploy compose files in `references/`. Replace `<nas-host>` and `<nas-user>` with your values.

| Stack | File | Port | Description |
|-------|------|------|-------------|
| **Nginx Proxy Manager** | `nginx-reverse-proxy.yml` | 80, 443, 81 | Reverse proxy with SSL termination and web UI |
| **FreshRSS** | `freshrss.yml` | 8280 | RSS feed aggregator with PostgreSQL backend |
| **BookLore** | `booklore.yml` | 6060 | Digital library for EPUB/PDF/CBZ with auto-metadata |
| **Telegram Bot** | `telegram-bot.yml` | — | Python bot running 24/7, custom Dockerfile |

**Quick deploy any stack:**
```bash
# Example: deploy FreshRSS
crane pull freshrss/freshrss:latest /tmp/freshrss.tar
crane pull postgres:16-alpine /tmp/postgres-16-alpine.tar
docker load -i /tmp/freshrss.tar
docker load -i /tmp/postgres-16-alpine.tar
docker compose -f references/freshrss.yml up -d
```

**Multi-service architecture** (recommended for production):
```
Nginx Proxy Manager (:80/:443)
  ├── FreshRSS    → localhost:8280
  ├── BookLore    → localhost:6060
  └── Other apps  → localhost:XXXX
```

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| `permission denied` on docker socket | User not in `docker` group | `sudo usermod -aG docker <user>` + re-login |
| Group added but still denied | Session not refreshed | Log out and back in, or `newgrp docker` |
| `connection reset by peer` on pull | NAS can't reach Docker Hub | Use `crane pull` + `docker load` workflow |
| `403 Forbidden` on volume | Files don't exist on NAS | `scp` files to NAS first |
| `port already in use` | Another service on that port | Change port mapping or stop conflicting service |
| `sudo` needs password via SSH | No TTY allocated | Use `ssh -t` for interactive, or add user to docker group |
