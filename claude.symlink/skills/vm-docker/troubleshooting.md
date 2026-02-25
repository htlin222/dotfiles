# Troubleshooting

## Common Issues

| Problem | Cause | Fix |
|---------|-------|-----|
| `502 Bad Gateway` | Container not on `traefik-proxy` network, or wrong container name/port | `docker network inspect traefik-proxy`, verify service URL in dynamic config |
| `404 Not Found` | Router rule doesn't match, or YAML errors in dynamic config | Check `~/traefik/dynamic/<service>.yml`, test with `curl -v` |
| Service works on host port but not via Traefik | Missing `networks: traefik-proxy` in compose | Add network, `docker compose up -d` to recreate |
| Homepage doesn't show service | Wrong container name in `services.yaml`, or container not running | Match `container:` to `docker ps` output |
| BasicAuth not prompting | Missing `auth@file` middleware in router | Add `- auth@file` to middlewares list |
| Sub-path breaks app assets (CSS/JS 404) | App's `URL_PATH`/`BASE_URL` only affects link generation, NOT route mounting — app still serves at `/` | Use `stripPrefix` in Traefik AND set the app's sub-path env var. Test CSS/JS assets load, not just HTML |
| SPA blank page under subpath | App has hardcoded `<base href="/">` with no subpath config (e.g. Booklore). `stripPrefix` makes the HTML load but all asset/API requests go to `/` hitting Homepage instead | **No Traefik fix** — expose host port and use `href: http://172.16.252.7:<port>` in Homepage. Check upstream for subpath support (e.g. [booklore#1886](https://github.com/booklore-app/booklore/issues/1886)) |
| HedgeDoc assets broken via IP | `CMD_DOMAIN=vm.local` but accessing via `172.16.252.7` — all generated URLs point to wrong hostname | Change `CMD_DOMAIN` in docker-compose.yml to match access IP/hostname, then `docker compose up -d` |
| Traefik dashboard empty (no routers/services) | Dashboard HTML loads but JS API calls to `/api/...` miss the `/traefik` router and hit Homepage catch-all | Add a second router `PathPrefix(/api)` → `api@internal` with auth. Do NOT use `api.basePath` — it breaks insecure port (8080) and Homepage widget |
| `permission denied` on docker socket | User not in `docker` group | `sudo usermod -aG docker htlin222` + re-login |

## Debugging Commands

```bash
# Check container is on traefik-proxy network
docker network inspect traefik-proxy | grep <container>

# Test Traefik routing (bypass system proxy)
curl -sI --noproxy '*' http://localhost/<service>/

# Check Traefik logs for routing errors
docker logs traefik 2>&1 | grep <service>

# Check app logs
docker logs <container> 2>&1 | tail -20

# Verify container name matches dynamic config
docker ps --format '{{.Names}}'
```
