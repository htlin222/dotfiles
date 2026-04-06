---
name: env-dx
description: Scan environment for dev readiness — tools, runtimes, permissions. Use in new containers.
---

# Environment DX Scanner

Runs a single diagnostic script to audit the current environment (container or local) for developer tools, runtimes, connectivity, and write permissions.

## Usage

- `/env-dx` — full scan (all sections)
- `/env-dx quick` — skip network and disk checks (faster)

## Workflow

### Step 1: Run the scan

```bash
bash ~/.claude/skills/env-dx/scripts/scan.sh
```

For quick mode:

```bash
bash ~/.claude/skills/env-dx/scripts/scan.sh --quick
```

The script is read-only and safe to run. It creates a temp file to test write permissions and a temp uv project to test `uv add`, both cleaned up immediately.

### Step 2: Parse output

Each line uses a status prefix:
- `[OK]` — tool found / check passed
- `[MISSING]` — tool not found
- `[WARN]` — partial issue (old version, limited access)
- `[FAIL]` — check failed (no write permission, no network)

### Step 3: Present results

**Summary table** — one row per category (System, Container, Required Tools, Runtimes, Permissions, Network, Resources) with rollup status.

**Issues** — list every `[MISSING]`, `[WARN]`, `[FAIL]` item with a concrete fix command adapted to the detected OS:
- Debian/Ubuntu: `apt-get install -y <pkg>`
- Alpine: `apk add <pkg>`
- RHEL/Fedora: `dnf install <pkg>`
- macOS: `brew install <pkg>`
- Python tools: `pipx install <pkg>` or `uv tool install <pkg>`
- Rust tools: `cargo install <pkg>`
- Node tools: `pnpm add -g <pkg>` or `npm install -g <pkg>`

**Recommendations** — prioritized by impact (permissions > required tools > optional tools > nice-to-haves).

### Step 4: Offer follow-up

Ask if the user wants to:
1. Install missing tools (generate a single install script for their OS)
2. Deep-dive a specific area
3. Save the report to a file
