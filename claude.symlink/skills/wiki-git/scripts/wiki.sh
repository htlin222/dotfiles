#!/usr/bin/env bash
# wiki.sh — plumbing for curating a GitHub repo's wiki (the separate <repo>.wiki.git).
# Subcommands are deterministic; the *content* is written by the model per SKILL.md.
#
#   wiki.sh has-content <owner/repo>       -> prints "yes" (wiki has pages) or "no"
#   wiki.sh enabled     <owner/repo>       -> prints has_wiki flag (true/false)
#   wiki.sh enable      <owner/repo>       -> turn the wiki feature ON (needs gh auth)
#   wiki.sh clone       <owner/repo> <dir> -> clone <repo>.wiki.git into <dir>
#   wiki.sh publish     <dir> <message>    -> add -A, commit (unsigned), push
#
# Notes:
#   - "has-content" is the real test of whether a wiki exists to curate: has_wiki=true
#     only means the feature is toggled on; the .wiki.git repo does not exist until the
#     first page is created (via the web UI or an initial push).
#   - publish disables GPG signing to stay non-interactive; it uses the ambient git
#     user.name/user.email (override with GIT_AUTHOR_NAME/GIT_AUTHOR_EMAIL if needed).
set -euo pipefail

die() { echo "wiki.sh: $*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "missing dependency: $1"; }

cmd="${1:-}"; shift || true

case "$cmd" in
  has-content)
    repo="${1:?usage: wiki.sh has-content <owner/repo>}"; need git
    if [ -n "$(git ls-remote "https://github.com/${repo}.wiki.git" 2>/dev/null)" ]; then
      echo yes
    else
      echo no
    fi
    ;;

  enabled)
    repo="${1:?usage: wiki.sh enabled <owner/repo>}"; need gh
    gh api "repos/${repo}" --jq '.has_wiki'
    ;;

  enable)
    repo="${1:?usage: wiki.sh enable <owner/repo>}"; need gh
    gh api -X PATCH "repos/${repo}" -F has_wiki=true --jq '.has_wiki'
    ;;

  clone)
    repo="${1:?usage: wiki.sh clone <owner/repo> <dir>}"
    dir="${2:?usage: wiki.sh clone <owner/repo> <dir>}"; need git
    [ -e "$dir" ] && die "target exists: $dir (remove it first)"
    git clone "https://github.com/${repo}.wiki.git" "$dir"
    ;;

  publish)
    dir="${1:?usage: wiki.sh publish <dir> <message>}"
    msg="${2:?usage: wiki.sh publish <dir> <message>}"; need git
    cd "$dir"
    git add -A
    if git diff --cached --quiet; then
      echo "wiki.sh: nothing to commit in $dir" >&2; exit 0
    fi
    git -c commit.gpgsign=false commit -m "$msg"
    git push origin HEAD
    ;;

  *)
    die "unknown subcommand '${cmd}'. See header of this script for usage."
    ;;
esac
