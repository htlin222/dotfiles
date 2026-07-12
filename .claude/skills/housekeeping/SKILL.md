---
name: housekeeping
description: Use when macOS disk space is low, "disk full", 硬碟空間不夠, startup disk almost full, or before installing something large — diagnoses what is eating space and reclaims it safely
---

# macOS Disk Housekeeping

## Overview

Diagnose → reclaim safe targets → verify. Known-safe cleanup only; never touch personal data. `reference/prune.sh` automates the whole flow (dry-run by default).

## Diagnosis

```bash
df -h /System/Volumes/Data        # the REAL usage (df / shows the sealed system snapshot)
du -sh ~/Library/* | sort -rh | head        # usual suspects
du -sh ~/* ~/.[a-z]* 2>/dev/null | sort -rh | head
tmutil listlocalsnapshots /       # MSUPrepareUpdate = staged macOS update
```

## Known hogs on this machine (2026-07 findings)

| Target | Typical size | Action |
|---|---|---|
| `~/Library/Application Support/Claude/vm_bundles` | ~10G | delete if VM not running (`pgrep -fl claudevm`); rebuilds on demand |
| `~/Library/pnpm` store | 7G+ | `pnpm store prune` |
| `~/Library/Caches/{com.spotify.client,BraveSoftware,Google,com.brave.Browser,pip,go-build,node-gyp}` | ~4G | delete outright |
| `~/.cache/uv` | 2G+ | `uv cache prune` (remainder is referenced by live venvs — leave it) |
| `/opt/homebrew` | 20G+ | `brew cleanup --prune=all && brew autoremove` |
| `MSUPrepareUpdate` snapshot | few GB | finish the pending macOS update (reboot) — `softwareupdate -l` to see it |

## Do NOT delete

- `~/Library/Caches/ms-playwright*` — breaks E2E until `playwright install`
- `~/.cache/codex-runtimes` — Codex plugin runtime
- `~/Pictures`, `~/Library/Group Containers`, Mail — personal data
- leftover `~/.cache/uv` after prune — hardlinked into venvs

## Gotchas

- **`rip` does not free space.** It moves files to `/tmp/graveyard-$USER` on the *same volume*. After ripping large targets run `yes | rip --decompose` and re-check `df`.
- **`brew cleanup` frees nothing when packages are outdated** — it only deletes versions older than the installed-latest. Upgrade first if you want real savings.
- **`uv cache prune` vs `clean`**: prune keeps in-use entries (correct); clean wipes all (pointless — hardlinked files free nothing).

## Automation

```bash
reference/prune.sh          # dry-run report of known-safe targets
reference/prune.sh --apply  # actually clean them

# Find NEW candidates: large + old + cold, ranked by "storage rent"
# (score = size_GB × idle_days; gates on created>180d AND atime>90d;
#  top hits cross-checked with Spotlight kMDItemLastUsedDate)
reference/clean-large-and-olds.sh                       # scan $HOME, top 20
reference/clean-large-and-olds.sh --root DIR --min-size 50 --top 30
```

`clean-large-and-olds.sh` is report-only — review, then `rip <paths>` + `yes | rip --decompose`.
