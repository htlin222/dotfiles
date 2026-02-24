# Traefik + Homepage Infrastructure

How to recreate the Traefik reverse proxy and Homepage dashboard from scratch.

## Network

```bash
docker network create traefik-proxy
```

## Directory Structure

```bash
mkdir -p ~/traefik/dynamic
mkdir -p ~/homepage/config
```

## Traefik Static Config

Write `~/traefik/traefik.yml`:

```yaml
log:
  level: INFO

api:
  insecure: true
  dashboard: true
  basePath: /traefik

entryPoints:
  web:
    address: ":80"

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
    network: traefik-proxy
  file:
    directory: /etc/traefik/dynamic
    watch: true
```

## Traefik Dynamic Configs

### BasicAuth (`~/traefik/dynamic/auth.yml`)

```yaml
http:
  middlewares:
    auth:
      basicAuth:
        users:
          - "htlin222:<htpasswd-hash>"
```

Generate the hash:
```bash
htpasswd -n htlin222
```

### Dashboard route (`~/traefik/dynamic/traefik-dashboard.yml`)

```yaml
http:
  routers:
    traefik-api:
      rule: "PathPrefix(`/traefik`)"
      entryPoints:
        - web
      middlewares:
        - auth@file
      service: api@internal
      priority: 10
```

## Traefik Container

```bash
docker run -d \
  --name traefik \
  --restart unless-stopped \
  --network traefik-proxy \
  -p 80:80 \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v ~/traefik/traefik.yml:/etc/traefik/traefik.yml:ro \
  -v ~/traefik/dynamic:/etc/traefik/dynamic:ro \
  traefik:v3.3
```

## Homepage Container

```bash
docker run -d \
  --name homepage \
  --restart unless-stopped \
  --network traefik-proxy \
  -v ~/homepage/config:/app/config \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -l traefik.enable=true \
  -l "traefik.http.routers.homepage.rule=PathPrefix(\`/\`)" \
  -l traefik.http.routers.homepage.entrypoints=web \
  -l traefik.http.services.homepage.loadbalancer.server.port=3000 \
  ghcr.io/gethomepage/homepage:latest
```

## Homepage Config Files

### `~/homepage/config/docker.yaml`

```yaml
my-docker:
  socket: /var/run/docker.sock
```

### `~/homepage/config/settings.yaml`

```yaml
title: My Home Dashboard

background:
  image: ""

theme: dark
color: slate

useEqualHeights: true

layout:
  Media:
    style: row
    columns: 3
  Infrastructure:
    style: row
    columns: 3
```

### `~/homepage/config/services.yaml`

```yaml
---
- Media:
    - Booklore:
        href: /booklore
        description: Book management
        icon: mdi-book-open-variant
        server: my-docker
        container: kavita-booklore-1

- Infrastructure:
    - Traefik:
        href: /traefik/dashboard/
        description: Reverse proxy dashboard
        icon: traefik
        server: my-docker
        container: traefik
        widget:
            type: traefik
            url: http://traefik:8080
```

## Verification

```bash
# Check Traefik is running
docker ps | grep traefik

# Check Homepage is running
docker ps | grep homepage

# Test routing
curl -I http://localhost/           # → Homepage
curl -I http://localhost/traefik    # → Traefik dashboard (requires auth)

# Check Traefik logs
docker logs traefik --tail 20
```

## Adding a New Service

1. Deploy the service on `traefik-proxy` network
2. Create `~/traefik/dynamic/<service>.yml` (see SKILL.md template)
3. Add entry to `~/homepage/config/services.yaml`
4. Verify: `curl -I http://localhost/<service>`
