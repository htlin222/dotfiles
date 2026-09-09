#!/usr/bin/env bash
#
# codespace_prewarm.sh — runs during the Codespaces PREBUILD (onCreateCommand).
#
# Everything here gets baked into the prebuild snapshot. Nothing that needs
# user-level secrets belongs in this file: those are not available until the
# codespace itself is created.
#
# Lives in htlin222/dotfiles so all repos share one copy. Each repo's
# .devcontainer/devcontainer.json curls it, so editing this file updates every
# repo on its next prebuild.
#
set -euo pipefail

log() { printf '\033[36m==>\033[0m %s\n' "$*"; }

# ---------------------------------------------------------------------------
# 1. The same apt packages start/setup_linux.sh installs.
#
# Installing them HERE means they land in the prebuild snapshot. When the
# dotfiles installer runs later at codespace-creation time, its `apt install`
# becomes a near-instant no-op instead of a 1-3 minute wait, every single time.
# ---------------------------------------------------------------------------
log "system packages"
sudo apt-get update -qq
# One at a time: a single package missing from this Ubuntu release would
# otherwise take the whole prebuild down with it under `set -e`.
for pkg in zsh tmux neovim git curl wget ripgrep fd-find fzf bat eza zoxide \
           build-essential unzip fontconfig; do
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends "$pkg" \
    || echo "  (skipped: $pkg unavailable)" >&2
done

# ---------------------------------------------------------------------------
# 2. Claude Code, via the native installer.
#
# Installs to ~/.local/bin. devcontainer.json puts that on PATH via remoteEnv
# so it survives the dotfiles symlinks replacing .zshrc / .bashrc later.
# ---------------------------------------------------------------------------
log "claude code"
curl -fsSL https://claude.ai/install.sh | bash

# ---------------------------------------------------------------------------
# 3. Language toolchain warmup — only if the repo actually has a manifest.
#    Dependencies are the slowest part of a cold start and the whole reason
#    prebuilds exist.
# ---------------------------------------------------------------------------
cd "${CODESPACE_VSCODE_FOLDER:-/workspaces/$(ls /workspaces | head -1)}" 2>/dev/null || exit 0

if [ -f package-lock.json ]; then
  log "npm ci"; npm ci --no-audit --no-fund || true
elif [ -f pnpm-lock.yaml ]; then
  log "pnpm install"; corepack enable && pnpm install --frozen-lockfile || true
elif [ -f yarn.lock ]; then
  log "yarn install"; yarn install --frozen-lockfile || true
fi

if [ -f uv.lock ]; then
  log "uv sync"; curl -LsSf https://astral.sh/uv/install.sh | sh && "$HOME/.local/bin/uv" sync || true
elif [ -f requirements.txt ]; then
  log "pip install"; pip install -q -r requirements.txt || true
elif [ -f pyproject.toml ]; then
  log "pip install ."; pip install -q -e . || true
fi

log "prewarm done"
