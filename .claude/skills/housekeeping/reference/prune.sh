#!/usr/bin/env bash
# macOS disk housekeeping — safe-target cleanup.
# Dry-run by default; pass --apply to actually delete.
# Companion to ../SKILL.md (gotchas: rip graveyard, brew outdated, uv hardlinks).
set -euo pipefail

APPLY=0
[[ "${1:-}" == "--apply" ]] && APPLY=1

# Caches that are always safe to delete outright (rebuilt on demand).
SAFE_CACHES=(
  "$HOME/Library/Caches/com.spotify.client"
  "$HOME/Library/Caches/BraveSoftware"
  "$HOME/Library/Caches/com.brave.Browser"
  "$HOME/Library/Caches/Google"
  "$HOME/Library/Caches/pip"
  "$HOME/Library/Caches/go-build"
  "$HOME/Library/Caches/node-gyp"
)

VM_BUNDLE="$HOME/Library/Application Support/Claude/vm_bundles/claudevm.bundle"

say() { printf '\n\033[1m== %s ==\033[0m\n' "$*"; }

say "Disk before"
df -h /System/Volumes/Data | tail -1

say "Safe cache targets"
for d in "${SAFE_CACHES[@]}"; do
  [[ -e "$d" ]] && du -sh "$d" 2>/dev/null
done

if [[ -e "$VM_BUNDLE" ]]; then
  say "Claude VM bundle"
  du -sh "$VM_BUNDLE"
  if pgrep -f claudevm >/dev/null 2>&1; then
    echo "SKIP: VM is running — not touching the bundle."
    VM_BUNDLE=""
  fi
else
  VM_BUNDLE=""
fi

say "Pending macOS update snapshot?"
tmutil listlocalsnapshots / 2>/dev/null | grep -i MSUPrepareUpdate \
  && echo "-> a staged macOS update is holding space; reboot/update to free it." \
  || echo "none"

if [[ $APPLY -eq 0 ]]; then
  say "DRY RUN — nothing deleted. Re-run with --apply to clean."
  exit 0
fi

say "Pruning package stores"
command -v pnpm >/dev/null && pnpm store prune
command -v uv   >/dev/null && uv cache prune
command -v brew >/dev/null && { brew cleanup --prune=all; brew autoremove; }

say "Deleting safe caches + VM bundle"
targets=()
for d in "${SAFE_CACHES[@]}"; do [[ -e "$d" ]] && targets+=("$d"); done
[[ -n "$VM_BUNDLE" ]] && targets+=("$VM_BUNDLE")
if [[ ${#targets[@]} -gt 0 ]]; then
  if command -v rip >/dev/null; then
    # rip only moves to /tmp/graveyard-$USER (same volume) — decompose to actually free space
    yes | rip "${targets[@]}"
    yes | rip --decompose
  else
    rm -rf "${targets[@]}"
  fi
fi

say "Disk after"
df -h /System/Volumes/Data | tail -1
