# Git Related Functions

# Check if in git repo
function is_git_repo() {
  git rev-parse --is-inside-work-tree &>/dev/null
}

# Git add, AI commit, push
function zgit() {
  git add -A
  aicommits --type conventional
  git push
}

# Quick git add, commit, push
function ygit() {
  git add -A
  git commit -m "Routine: Upload"
  git push
}

# Git add, AI commit, push (alias style)
gitacp() {
  git add .
  aicommits
  git push
}

# Dotfiles push with AI commit
function dp() {
  cd $DOTFILES
  git -C $DOTFILES add .
  aicommits
  git -C $DOTFILES push
  cd -
}

# Dotfiles pull
function dotpull() {
  git restore $DOTFILES
  git -C $DOTFILES pull
}

# Release dotfiles with book link
dotrelease() {
  local version="$1"
  if [[ -z "$version" ]]; then
    echo "Usage: dotrelease <version> (e.g., dotrelease v1.0.3)"
    return 1
  fi
  cd "$DOTFILES" || return 1
  git tag -a "$version" -m "$version"
  git push origin "$version"
  gh release create "$version" \
    --title "$version" \
    --notes $'[終端人生：純 CLI 開發者的完全指南](https://htlin222.github.io/dotfiles/)\n\n---\n\n'"$(git log --oneline -5 | sed 's/^/- /')"
  cd -
}

git-top() { cd "$(git rev-parse --show-toplevel 2>/dev/null)" || return; }
