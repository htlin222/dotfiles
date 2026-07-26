# GitHub Actions CI/CD for Cloudflare Pages

Push to `main` → assemble the site → deploy to Cloudflare Pages. Replace
`PROJECT` with the project name and `OWNER/REPO` with the GitHub slug. Adjust the
"Assemble static site" step to match the layout (a single folder, or specific
files copied into `dist/`).

## 1. Workflow — `.github/workflows/deploy-cloudflare.yml`

```yaml
name: Deploy to Cloudflare Pages

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read

concurrency:
  group: cloudflare-pages
  cancel-in-progress: true

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Check out
        uses: actions/checkout@v4

      - name: Assemble static site
        run: |
          # Produce a clean dist/ holding exactly what should be served.
          # Example: a single-page site plus a zh-TW/ subfolder.
          mkdir -p dist/zh-TW
          cp index.html dist/index.html
          cp zh-TW/index.html dist/zh-TW/index.html
          # For a whole folder instead: cp -R site/. dist/

      - name: Ensure Pages project exists
        env:
          CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          CLOUDFLARE_ACCOUNT_ID: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
        run: |
          npx --yes wrangler@4 pages project create PROJECT --production-branch=main 2>/dev/null \
            || echo "Pages project already exists — continuing."

      - name: Deploy to Cloudflare Pages
        uses: cloudflare/wrangler-action@v3
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
          command: pages deploy dist --project-name=PROJECT --branch=main
```

**Why "Ensure Pages project exists" is a plain `run` step:** it swallows the
"already exists" error with `|| echo` and exits 0, so the run stays green with
**no red annotation**. Do **not** implement this with `continue-on-error: true`
on the wrangler-action — that still leaves a red "Action failed" annotation on
every run even though the job passes.

## 2. Set the two repo secrets (token value is never printed)

```bash
set -a; . ./.env; set +a
printf '%s' "$CLOUDFLARE_API_TOKEN"  | gh secret set CLOUDFLARE_API_TOKEN  --repo OWNER/REPO
printf '%s' "$CLOUDFLARE_ACCOUNT_ID" | gh secret set CLOUDFLARE_ACCOUNT_ID --repo OWNER/REPO
gh secret list --repo OWNER/REPO
```

Referencing `$CLOUDFLARE_API_TOKEN` (not the literal) keeps the secret out of
shell history and command output. `gh secret set` never echoes the value.

## 3. Trigger and verify

```bash
git push origin main
sleep 30
gh run list --repo OWNER/REPO --workflow "Deploy to Cloudflare Pages" --limit 1
curl -sI https://PROJECT.pages.dev/          # expect HTTP 200
```

If a run is red, inspect it: `gh run view <id> --repo OWNER/REPO --log-failed`.
The most common cause is a missing/mis-scoped token — recreate it from the
"Cloudflare Pages" template at https://dash.cloudflare.com/profile/api-tokens.

## Notes

- `<PROJECT>.pages.dev` must be globally unique; if taken, Cloudflare assigns a
  suffix and reports the real URL in the deploy output.
- A benign `Node.js 20 is deprecated` notice from `actions/checkout` and
  `wrangler-action` is upstream and does not fail the run.
- One CI target is cleaner: if a GitHub Pages workflow also exists, remove it so
  Cloudflare Pages is the sole deploy path.
