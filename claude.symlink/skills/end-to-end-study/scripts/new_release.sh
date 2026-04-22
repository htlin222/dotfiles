#!/usr/bin/env bash
# Build the manuscript PDF and create a tagged GitHub release with PDF + .tex + source bundle.
#
# Usage:
#   scripts/new_release.sh <project-dir> <version> "<title>" "<notes>" [--allow-dirty]
#
# Example:
#   scripts/new_release.sh ./my-study v1.0.0 "v1.0.0 - initial release" "First scientific release."
#
# Pre-flight checks: gh / git / latexmk installed, gh authenticated, git clean,
# tag not yet used, PDF rebuilds. Artefacts are staged inside the project (not
# /tmp) so embargoed manuscripts do not leak on shared hosts. Placeholder DOIs
# (`10.0000/placeholder`) in references.bib fail the release.
set -euo pipefail
IFS=$'\n\t'

err() { printf 'error: %s\n' "$*" >&2; exit 1; }
note() { printf '::: %s\n' "$*"; }

if [[ $# -lt 4 ]]; then
  err "usage: new_release.sh <project-dir> <version> \"<title>\" \"<notes>\" [--allow-dirty]"
fi

PROJECT_DIR="$1"
VERSION="$2"
TITLE="$3"
NOTES="$4"
ALLOW_DIRTY=0
[[ "${5-}" == "--allow-dirty" ]] && ALLOW_DIRTY=1

[[ -d "$PROJECT_DIR" ]] || err "project directory not found: $PROJECT_DIR"
cd "$PROJECT_DIR"
SLUG="$(basename "$(pwd)")"

# --- pre-flight ---
for cmd in gh git latexmk tar; do
  command -v "$cmd" >/dev/null 2>&1 || err "$cmd is required but not installed"
done

git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || err "$PROJECT_DIR is not a git repository"

if ! gh auth status >/dev/null 2>&1; then
  err "gh is not authenticated; run: gh auth login"
fi

if [[ $ALLOW_DIRTY -eq 0 ]]; then
  if [[ -n "$(git status --porcelain)" ]]; then
    err "working tree is dirty; commit or pass --allow-dirty to override"
  fi
fi

if git rev-parse -q --verify "refs/tags/${VERSION}" >/dev/null; then
  err "local tag ${VERSION} already exists"
fi
if gh release view "${VERSION}" --json tagName -q .tagName >/dev/null 2>&1; then
  err "remote release ${VERSION} already exists"
fi

# --- lint for placeholder artefacts ---
if grep -q "10.0000/placeholder" manuscript/references.bib 2>/dev/null; then
  err "manuscript/references.bib still contains 10.0000/placeholder DOIs; replace before releasing"
fi
if grep -q "Anonymous" manuscript/main.tex 2>/dev/null; then
  printf 'warn: manuscript/main.tex still uses "Anonymous" in authors; continuing\n' >&2
fi

# --- build PDF fresh ---
note "building PDF"
(cd manuscript && make)

[[ -f manuscript/main.pdf ]] || err "manuscript/main.pdf was not produced"

# --- stage release artefacts locally (never /tmp) ---
STAGE="release/${VERSION}"
rm -rf "$STAGE"
mkdir -p "$STAGE"
cp -f manuscript/main.pdf "${STAGE}/${SLUG}.pdf"
cp -f manuscript/main.tex "${STAGE}/${SLUG}.tex"
cp -f manuscript/references.bib "${STAGE}/references.bib"

# Figure files: may not exist yet on first release
shopt -s nullglob
FIGS=(manuscript/Fig*.pdf)
shopt -u nullglob
if [[ ${#FIGS[@]} -eq 0 ]]; then
  note "no manuscript/Fig*.pdf found - source bundle will omit figures"
fi

# Create source bundle; omit missing globs gracefully
tar_cmd=(tar -czf "${STAGE}/source-bundle.tar.gz"
  manuscript/main.tex manuscript/references.bib
  manuscript/Makefile manuscript/latexmkrc
  analysis README.md LICENSE .github/workflows/release.yml)
[[ ${#FIGS[@]} -gt 0 ]] && tar_cmd+=("${FIGS[@]}")
if [[ -f docs/prereg.md ]]; then
  tar_cmd+=(docs/prereg.md)
fi
"${tar_cmd[@]}"

# --- create release via GitHub API (avoids local GPG signing) ---
note "creating release ${VERSION}"
gh release create "$VERSION" \
  --title "$TITLE" \
  --notes "$NOTES" \
  "${STAGE}/${SLUG}.pdf" \
  "${STAGE}/${SLUG}.tex" \
  "${STAGE}/references.bib" \
  "${STAGE}/source-bundle.tar.gz"

note "released ${VERSION} for ${SLUG}"
note "staged artefacts at ${STAGE}"
