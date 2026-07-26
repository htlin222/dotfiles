# Templates

## Docker Compose

```yaml
services:
  <service>:
    image: <image>:<tag>
    restart: unless-stopped
    # No host ports — Traefik routes via traefik-proxy network
    volumes:
      - /home/htlin222/docker/<service>/data:/app/data
    environment:
      TZ: Asia/Taipei
    networks:
      - traefik-proxy

networks:
  traefik-proxy:
    external: true
```

For services with a database, add an internal network:

```yaml
networks:
  traefik-proxy:
    external: true
  <service>-internal:
    driver: bridge
```

Only the app container joins both networks; the DB only joins internal.

## Traefik Dynamic Config

File: `~/traefik/dynamic/<service>.yml`

```yaml
http:
  routers:
    <service>:
      rule: "PathPrefix(`/<service>`)"
      entryPoints:
        - web
      middlewares:
        - auth@file
        - <service>-strip
      service: <service>
      priority: 10

  middlewares:
    <service>-strip:
      stripPrefix:
        prefixes:
          - /<service>

  services:
    <service>:
      loadBalancer:
        servers:
          - url: "http://<container-name>:<internal-port>"
```

### Rules

- File: one per service at `~/traefik/dynamic/<service>.yml`
- Router: `PathPrefix(\`/<service>\`)` with priority `10`
- Middleware: `auth@file` (BasicAuth) + `<service>-strip` (stripPrefix)
- Service URL: `http://<container-name>:<port>` (container name from `docker ps`)
- Traefik watches the directory — no restart needed

## Homepage Entry

Add to `~/homepage/config/services.yaml`:

### Subpath-aware apps (routed via Traefik)

```yaml
- <Group>:
    - <Name>:
        href: /<service>
        description: <short description>
        icon: <icon-name>
        server: my-docker
        container: <container-name>
```

### Apps without subpath support (direct port access)

```yaml
- <Group>:
    - <Name>:
        href: http://172.16.252.7:<host-port>
        description: <short description>
        icon: <icon-name>
        server: my-docker
        container: <container-name>
```

> **Which to use?** Check if the app supports a `BASE_PATH`/`BASE_URL`/context-path config.
> If it has hardcoded `<base href="/">` with no config → use direct port.
> Known: Booklore = direct port, HedgeDoc = subpath-aware (`CMD_URL_PATH`).

- Icons: `mdi-*` (Material Design) or service name (e.g., `traefik`, `hedgedoc`)
- New groups also need an entry in `~/homepage/config/settings.yaml`:
  ```yaml
  layout:
    <Group>:
      style: row
      columns: 3
  ```

## Makefile

```makefile
SERVICE := <service>
IMAGES  := <image>:<tag>
COMPOSE := docker compose
CRANE   := ~/go/bin/crane

.PHONY: pull load up down ps logs verify clean

pull:
	@for img in $(IMAGES); do \
		echo "Pulling $$img..."; \
		$(CRANE) pull $$img /tmp/$$(echo $$img | tr '/:' '-').tar; \
	done

load:
	@for img in $(IMAGES); do \
		tarfile=/tmp/$$(echo $$img | tr '/:' '-').tar; \
		echo "Loading $$tarfile..."; \
		docker load -i $$tarfile; \
	done

up: pull load
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f

verify:
	$(COMPOSE) ps
	@echo "---"
	curl -sI --noproxy '*' http://localhost/$(SERVICE) | head -5
	@echo "---"
	@echo "Check dashboard: http://vm.local/"

clean: down
	$(COMPOSE) rm -f
	docker image prune -f
```

## Image Workflow

```bash
# Pull as tarball (no daemon needed)
~/go/bin/crane pull <image>:<tag> /tmp/<name>.tar

# Load into Docker
docker load -i /tmp/<name>.tar

# Verify
docker images | grep <name>
```
