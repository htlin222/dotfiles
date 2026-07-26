---
name: cf-page
description: Deploys a static site (a single HTML file or a folder) to Cloudflare Pages — both a one-command local wrangler deploy and a GitHub Actions CI/CD pipeline — wiring up .env/.env.example and encrypted repo secrets. Use when the user wants to publish or deploy a static site or HTML to Cloudflare Pages, set up CF Pages CI/CD, mentions "wrangler pages" or "deploy to cloudflare", or asks for "cf-page".
---

# Cloudflare Pages deploy (cf-page)

Ship a static site to Cloudflare Pages two ways from one setup: `./deploy.sh` locally, and GitHub Actions on every push to `main`. Credentials live in `.env` (gitignored); only `.env.example` is committed.

## The one thing the user must do — creating the token

The API token is the only manual step. Tell the user explicitly and link it:

> **Open https://dash.cloudflare.com/profile/api-tokens → "Create Token" → pick the "Cloudflare Pages" template (Edit) → Continue to summary → Create Token → copy it.**

Then they paste it into `.env` (see below). Everything else — account ID, project creation, deploy, CI secrets — is automated.

## Prerequisites

- `gh` authenticated (`gh auth status`) — for creating the repo and setting CI secrets.
- `wrangler` via `npx --yes wrangler@4` — no install needed.
- Account ID: `npx wrangler whoami` prints it if the user has run `wrangler login`; otherwise it is on the dashboard (Workers & Pages → right sidebar). Account ID is **not** secret.
- The site is static: a folder with an `index.html` at its served root. Cloudflare Pages serves it directly — no build step.

## Setup checklist

1. Choose a **project name** — becomes `https://<name>.pages.dev` (globally unique).
2. Add `.env.example` (committed) and `.env` (gitignored) — templates below.
3. Fix `.gitignore` — ignore `.env` and `.env.*`, keep `!.env.example`, ignore `dist/` and `.wrangler/`.
4. Get the token (link above) → paste into `.env`. Get account ID (`npx wrangler whoami`) → paste into `.env`.
5. **Local deploy:** copy `scripts/deploy.sh` into the repo, `chmod +x`, run it.
6. **CI/CD:** add the workflow and set two repo secrets — see [references/github-actions.md](references/github-actions.md).
7. **Verify:** `curl -sI https://<project>.pages.dev/`.

## .env.example — commit this

```sh
# Cloudflare Pages credentials. Copy to .env and fill in. .env is gitignored.
# Token: https://dash.cloudflare.com/profile/api-tokens  ("Cloudflare Pages" template)
CLOUDFLARE_API_TOKEN=
# Account ID: run `npx wrangler whoami`
CLOUDFLARE_ACCOUNT_ID=
# Pages project name  ->  https://<name>.pages.dev
CF_PAGES_PROJECT=my-site
# Optional: directory to deploy (default .) and production branch (default main)
# CF_PAGES_DIR=.
# CF_PAGES_BRANCH=main
```

## .env — create locally, never commit

```sh
CLOUDFLARE_API_TOKEN=          # user pastes the token here
CLOUDFLARE_ACCOUNT_ID=         # from `npx wrangler whoami`
CF_PAGES_PROJECT=my-site
```

## .gitignore — ensure these lines

```gitignore
.env
.env.*
!.env.example
dist/
.wrangler/
```

The `!.env.example` line is essential — `.env.*` would otherwise hide the example you want committed.

## Local deploy

Copy `scripts/deploy.sh` into the repo (e.g. `tools/deploy.sh`), then:

```bash
chmod +x tools/deploy.sh
./tools/deploy.sh                 # deploys $CF_PAGES_DIR (default .) as $CF_PAGES_PROJECT
```

It sources `.env`, creates the Pages project on first run (ignoring "already exists"), and deploys with wrangler. If `.env` has no token but the user ran `wrangler login`, it falls back to that OAuth session.

## CI/CD (GitHub Actions)

Push to `main` → assemble the site → `wrangler pages deploy`. Full workflow YAML and the two `gh secret set` commands: **[references/github-actions.md](references/github-actions.md)**. Requires repo secrets `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID`.

## Safety — do not skip

- **Never commit `.env`.** Confirm `git check-ignore .env` prints `.env`. Before committing, guard: `git diff --cached --name-only | grep -qx .env` must find nothing.
- **Never print the token.** Set secrets via a variable piped to stdin, never echo the value:
  `printf '%s' "$CLOUDFLARE_API_TOKEN" | gh secret set CLOUDFLARE_API_TOKEN`.
- Account ID may be shared freely; the API token may not.
