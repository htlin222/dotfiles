---
name: funnel-config
description: Manage Tailscale Funnel routes. Use when configuring tunnels or external HTTPS access.
---

# Tailscale Funnel Route Management

## Discover Current State

```bash
# Get hostname
tailscale status --json | jq -r '.Self.DNSName' | sed 's/\.$//'

# List all routes
tailscale funnel status

# Check what's listening on which ports
lsof -i -P -n | grep LISTEN | grep -E ':(8080|3000|3030|5000)'
```

## Add a Service Route

```bash
# Root path (only one service can own /)
tailscale funnel --bg <port>

# Sub-path (multiple can coexist)
tailscale serve --bg --set-path /<path> http://localhost:<port>
```

**Rule:** Routes coexist. Adding a root route does NOT remove sub-path routes. Adding a sub-path does NOT remove the root route.

## Remove a Route

```bash
# Remove root
tailscale funnel --https=443 off

# Remove a sub-path
tailscale serve --https=443 --set-path /<path> off
```

## Health Check

After any route change, verify both local and external:

```bash
HOSTNAME=$(tailscale status --json | jq -r '.Self.DNSName' | sed 's/\.$//')

# Local
curl -s --max-time 5 http://127.0.0.1:<port>/health

# External (proves funnel works end-to-end)
curl -s --max-time 10 "https://${HOSTNAME}/<path>" -o /dev/null -w "%{http_code}\n"
```

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| External returns nothing | Funnel not active | `tailscale funnel --bg <port>` |
| External returns 502 | Service not running on that port | Start the service, check `lsof -i :<port>` |
| Route disappeared after restart | Funnel routes persist, but `tailscale serve` routes may not | Re-add with `tailscale serve --bg --set-path ...` |
| New route killed existing service | Won't happen — routes coexist | Verify with `tailscale funnel status` |
| GitHub webhooks not arriving | Hostname mismatch or funnel off | Check `tailscale funnel status`, compare with webhook URL |

## Principles

- One service per path. Never route two services to the same path.
- Prefer sub-paths for non-primary services to avoid root conflicts.
- Always verify with external curl after changes — local success doesn't prove funnel works.
- Funnel requires Tailscale Funnel to be enabled on the tailnet (ACL policy).
