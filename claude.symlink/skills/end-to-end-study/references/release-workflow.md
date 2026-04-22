# Private GitHub repo and tagged release workflow

## Prerequisites

- `gh` CLI authenticated with `admin:repo_hook`, `repo`, `workflow` scopes.
- `git` configured with user name + email (signing optional - see note below).
- The project compiles locally with `cd manuscript && make`.

## One-time repo creation

```bash
cd <project-dir>
git init -b main
git add -A
git commit -m "Initial release: <title>"
gh repo create <slug> --private --source=. --remote=origin --description="<one-line description>" --push
```

The slug is the kebab-case version of the primary claim (`topological-stratification-aml`, `transformer-drug-response`, etc.). Follow the convention that the slug is the exact same string used in the first release.

## Tagged release

Always use `gh release create` rather than a local `git tag && git push --tags`. The `gh release create` path creates the tag via the GitHub API, which sidesteps local GPG signing config that routinely fails in fresh environments.

```bash
# Stage release artefacts under stable names
yes | cp manuscript/main.pdf /tmp/<slug>.pdf
yes | cp manuscript/main.tex /tmp/<slug>.tex
yes | cp manuscript/references.bib /tmp/references.bib
tar -czf /tmp/source-bundle.tar.gz \
  manuscript/main.tex manuscript/references.bib manuscript/Fig*.pdf \
  manuscript/Makefile manuscript/latexmkrc \
  analysis README.md LICENSE .github/workflows/release.yml

# Create the tagged release
gh release create v<MAJOR>.<MINOR>.<PATCH> \
  --title "v<MAJOR>.<MINOR>.<PATCH> - <short descriptor>" \
  --notes "<one-paragraph release notes describing what changed in this tag>" \
  /tmp/<slug>.pdf /tmp/<slug>.tex /tmp/references.bib /tmp/source-bundle.tar.gz
```

## Version number semantics

- `v<MAJOR>.<MINOR>.<PATCH>` with the following bump policy:
  - **MAJOR**: scientific pivot of primary finding (e.g. v1 survival-only -> v2 drug-response-primary). Write a release note that explicitly states the pivot.
  - **MINOR**: reviewer-round revision that addresses convergent concerns from one full reviewer cycle.
  - **PATCH**: typos, terminology fixes, figure-label fixes, non-scientific edits.
- Start at `v1.0.0` for the first release (not `v0.1.0` - the first scientific release is never experimental).

## CI workflow

Ship `.github/workflows/release.yml` (template in `assets/github/release.yml`). The workflow:

1. Triggers on tag push matching `v*`.
2. Runs `xu-cheng/latex-action@v3` with `latexmk -pdf` against `manuscript/main.tex`.
3. Stages the CI-built PDF + tex into `release/` with the canonical name.
4. Uses `softprops/action-gh-release@v2` to upload artefacts to the release page.

The CI rebuild acts as a verification: if the PDF cannot be rebuilt from the tagged commit, the release is broken and must be fixed.

## Private vs public repo

- Default to private during manuscript preparation.
- Flip to public immediately before submission (`gh repo edit --visibility public`).
- Post-submission: maintain the release tag that was cited in the submitted manuscript, even after further revisions.

## Do-not-do

- Do not amend a commit that has already been tagged in a public release. Create a new commit and a new tag.
- Do not force-push `main` after a release is out.
- Do not remove a release even after pivoting primary findings - the release history is the review-response trail and is itself scholarly record.
- Do not commit files >100 MB. Pre-filter oversized raw data (supplementary xlsx, scRNA-seq matrices) via `.gitignore`; if they sneak in, `git rm --cached` and amend before pushing.

## Authentication tips

- `gh auth status` shows scopes; the workflow scope is required for actions.
- Classic tokens with all three scopes work best for headless environments.
- Signing commits is optional; signing tags causes `git push --tags` to fail when GPG is not configured. Use `gh release create` (server-side tag) to avoid the problem entirely.

## Example release-note template

```
<short descriptor>

<2-4 sentences: what changed since previous tag, including effect sizes>

<list of new artefacts if different from previous release>
```

Keep release notes honest: if this round's change was a pivot away from an earlier claim, say so.
