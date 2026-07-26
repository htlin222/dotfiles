#!/usr/bin/env sh
# Deploy a static site to Cloudflare Pages with wrangler, reading credentials
# from .env. Copy this into your repo (e.g. tools/deploy.sh) and `chmod +x` it.
#
#   1. cp .env.example .env            (once)
#   2. paste CLOUDFLARE_API_TOKEN into .env
#      (token: https://dash.cloudflare.com/profile/api-tokens -> "Cloudflare Pages")
#   3. ./tools/deploy.sh [site-dir]
#
# .env vars used: CLOUDFLARE_API_TOKEN, CLOUDFLARE_ACCOUNT_ID, CF_PAGES_PROJECT,
#                 CF_PAGES_DIR (default .), CF_PAGES_BRANCH (default main)
# With no token in .env, falls back to your `wrangler login` OAuth session.
set -eu

# Load .env from the current directory if present (auto-export each line).
if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  . ./.env
  set +a
fi

# An empty token would break the OAuth fallback — drop it if blank.
if [ -z "${CLOUDFLARE_API_TOKEN:-}" ]; then
  unset CLOUDFLARE_API_TOKEN 2>/dev/null || true
  echo "No CLOUDFLARE_API_TOKEN in .env — falling back to your wrangler login." >&2
fi

PROJECT=${CF_PAGES_PROJECT:?Set CF_PAGES_PROJECT (in .env) to your Pages project name}
DIR=${1:-${CF_PAGES_DIR:-.}}
BRANCH=${CF_PAGES_BRANCH:-main}
WRANGLER="npx --yes wrangler@4"

# Create the Pages project on first run; ignore "already exists".
$WRANGLER pages project create "$PROJECT" --production-branch="$BRANCH" >/dev/null 2>&1 \
  || echo "Pages project '$PROJECT' already exists (or creation skipped)."

# Deploy the production branch.
$WRANGLER pages deploy "$DIR" --project-name="$PROJECT" --branch="$BRANCH"
