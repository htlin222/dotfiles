---
name: publish-the-skill
description: Publish a skill folder as a .skill package to GitHub. Use when distributing skills.
---

# Publish The Skill

Publish any skill folder as a distributable `.skill` package on GitHub with automated CI releases.

## Requirements

- `gh` CLI authenticated
- Skill folder containing a valid `SKILL.md` with frontmatter (`name`, `description`)
- Git available

## Workflow

### 1. Gather info

Determine these values (ask if not obvious):

| Variable | Source | Example |
|----------|--------|---------|
| `SKILL_DIR` | Folder containing SKILL.md | `ebmt-handbook/` |
| `SKILL_NAME` | From SKILL.md frontmatter `name:` | `ebmt-handbook` |
| `REPO_NAME` | `{SKILL_NAME}-skill` | `ebmt-handbook-skill` |
| `GH_USER` | `gh api user --jq '.login'` | `htlin222` |
| `DESCRIPTION` | From SKILL.md frontmatter `description:` (first sentence, <160 chars) | |
| `LICENSE` | From SKILL.md or ask user | `CC BY 4.0` |

### 2. Create `.gitignore`

```
.DS_Store
*.zip
*.skill
```

### 3. Create GitHub Action

Write `.github/workflows/release.yml`:

```yaml
name: Build & Release Skill

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: write

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set version from SHA
        id: version
        run: |
          SHORT_SHA="${GITHUB_SHA::7}"
          echo "sha=${SHORT_SHA}" >> $GITHUB_OUTPUT

      - name: Package skill
        run: |
          cd SKILL_DIR
          zip -r ../SKILL_NAME.zip .
          cd ..
          cp SKILL_NAME.zip SKILL_NAME.skill

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: SKILL_NAME-${{ steps.version.outputs.sha }}
          path: SKILL_NAME.skill

      - name: Create GitHub Release
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          SHORT_SHA="${GITHUB_SHA::7}"
          TAG="v0.1.0-${SHORT_SHA}"
          cat > release-notes.md <<EOF
          ## SKILL_NAME skill

          **Version:** \`${SHORT_SHA}\`
          **Commit:** ${GITHUB_SHA}

          ### Install

          \`\`\`bash
          npx skills add GH_USER/REPO_NAME
          \`\`\`

          Or download the \`.skill\` file from assets below.
          EOF
          gh release create "${TAG}" \
            --title "SKILL_NAME skill ${TAG}" \
            --notes-file release-notes.md \
            SKILL_NAME.skill
```

Replace all `SKILL_DIR`, `SKILL_NAME`, `REPO_NAME`, `GH_USER` placeholders with actual values.

### 4. Create README.md

```markdown
# SKILL_NAME

[![Build & Release Skill](https://github.com/GH_USER/REPO_NAME/actions/workflows/release.yml/badge.svg)](https://github.com/GH_USER/REPO_NAME/actions/workflows/release.yml)
[![GitHub Release](https://img.shields.io/github/v/release/GH_USER/REPO_NAME?include_prereleases&label=skill%20version)](https://github.com/GH_USER/REPO_NAME/releases/latest)
[![License: LICENSE_BADGE](https://img.shields.io/badge/License-LICENSE_LABEL-lightgrey.svg)](LICENSE_URL)
[![Skills Protocol](https://img.shields.io/badge/protocol-vercel--labs%2Fskills-blue)](https://github.com/vercel-labs/skills)
[![Compatible Agents](https://img.shields.io/badge/agents-40%2B-green)](https://github.com/vercel-labs/skills#supported-agents)

> DESCRIPTION_ONE_LINER

## Install

\```bash
npx skills add GH_USER/REPO_NAME
npx skills add -g GH_USER/REPO_NAME        # global
npx skills add GH_USER/REPO_NAME --agent claude-code  # specific agent
\```

## What it does

WHAT_IT_DOES (extract from SKILL.md body)

## Skill structure

TREE_OUTPUT (run `tree SKILL_DIR`)

## Protocol

This skill follows the [vercel-labs/skills](https://github.com/vercel-labs/skills) protocol.
Each push to `main` triggers a GitHub Action that packages the skill as a `.skill` file
and creates a release tagged with the commit SHA.

## License

LICENSE_LINE
```

Replace all placeholders. Generate the tree from actual directory contents.

### 5. Git init, commit, and push

```bash
git init && git branch -M main
git add -A
git commit -m "Initial release: SKILL_NAME skill for AI coding agents"
gh repo create REPO_NAME --public \
  --description "DESCRIPTION_SHORT. Install: npx skills add GH_USER/REPO_NAME" \
  --source . --push
```

### 6. Verify

```bash
gh run list --repo GH_USER/REPO_NAME --limit 1
gh run watch <RUN_ID> --repo GH_USER/REPO_NAME --exit-status
gh release list --repo GH_USER/REPO_NAME --limit 1
```

Report the repo URL and install command to the user.
