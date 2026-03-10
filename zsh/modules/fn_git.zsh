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

# FZF git worktree navigator
function gitwt() {
  is_git_repo || { echo "Not a git repo"; return 1; }

  local preview_opts=()
  if (( COLUMNS >= 50 )); then
    preview_opts=(
      --preview '
        dir=$(echo {} | sed "s/\x1b\[[0-9;]*m//g" | awk "{print \$1}")
        echo "\033[35m== Branch ==\033[0m"
        git -C "$dir" branch --show-current 2>/dev/null
        echo ""
        echo "\033[35m== Last Commit ==\033[0m"
        git -C "$dir" log -1 --color=always --format="%h %s (%cr) <%an>" 2>/dev/null
        echo ""
        echo "\033[35m== Status ==\033[0m"
        git -C "$dir" status --short 2>/dev/null || echo "clean"
        echo ""
        echo "\033[35m== Recent Commits ==\033[0m"
        git -C "$dir" log --oneline --graph --color=always -15 2>/dev/null
      '
      --preview-window=right:55%:wrap
    )
  fi

  local worktree
  worktree=$(git worktree list | \
    awk '{
      path=$1; branch=$NF;
      gsub(/[\[\]]/, "", branch);
      printf "\033[36m%s\033[0m \033[33m%s\033[0m\n", path, branch
    }' | \
    fzf --ansi --height 80% --layout=reverse \
      --prompt="worktree > " \
      "${preview_opts[@]}" \
      --bind '?:toggle-preview')

  [[ -z "$worktree" ]] && return
  local dir=$(echo "$worktree" | sed 's/\x1b\[[0-9;]*m//g' | awk '{print $1}')
  cd "$dir" || return 1
}
