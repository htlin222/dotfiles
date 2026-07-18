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

  local mainbranch
  mainbranch=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##')
  if [[ -z "$mainbranch" ]]; then
    local b
    for b in main master; do
      git show-ref --verify --quiet "refs/heads/$b" && { mainbranch=$b; break; }
    done
  fi

  # Batch ref-level lookups once (O(1) subprocess each) instead of per-worktree:
  #   branch tip timestamps  -> one for-each-ref
  #   merged-branch set       -> one branch --merged
  # Only dirty status must be probed per worktree (working-tree scan).
  local -A branch_ts merged_set
  local bname bts mb
  while read -r bname bts; do
    branch_ts[$bname]=$bts
  done < <(git for-each-ref --format='%(refname:short) %(committerdate:unix)' refs/heads 2>/dev/null)
  while read -r mb; do
    merged_set[$mb]=1
  done < <(git branch --merged "$mainbranch" --format='%(refname:short)' 2>/dev/null)

  # Build rows in the CURRENT shell (via process substitution, not a pipe
  # subshell) so per-worktree git calls and locals behave predictably.
  # NOTE: never name the loop var `path` — in zsh `path` is tied to $PATH,
  # so assigning it wipes PATH and every later `git` call fails silently.
  # Two groups: unmerged (+ main) on top, merged at the bottom.
  local -a rows_top rows_bottom dirty_lines
  local wt_line wt_path branch gsub_branch ts marker status_out clean grp
  local sl x y staged unstaged untracked
  while IFS= read -r wt_line; do
    [[ -z "$wt_line" ]] && continue
    wt_path=${wt_line%% *}
    branch=${wt_line##* }
    gsub_branch=${branch//[\[\]]/}
    ts=${branch_ts[$gsub_branch]:-0}
    if [[ "$gsub_branch" == "$mainbranch" || "$gsub_branch" == main || "$gsub_branch" == master ]]; then
      marker=$'\033[34m◆ trunk\033[0m'; grp=top
    elif [[ -n "${merged_set[$gsub_branch]}" ]]; then
      marker=$'\033[32m✓ merged\033[0m'; grp=bottom
    else
      marker=$'\033[33m● unmerged\033[0m'; grp=top
    fi
    status_out=$(git -C "$wt_path" status --porcelain 2>/dev/null)
    if [[ -n "$status_out" ]]; then
      dirty_lines=("${(@f)status_out}")
      # porcelain "XY path": X=index/staged, Y=worktree/unstaged, "??"=untracked
      staged=0 unstaged=0 untracked=0
      for sl in "${dirty_lines[@]}"; do
        x=${sl[1]} y=${sl[2]}
        if [[ "$x" == "?" ]]; then
          (( untracked++ ))
        else
          [[ "$x" != " " ]] && (( staged++ ))
          [[ "$y" != " " ]] && (( unstaged++ ))
        fi
      done
      clean=""
      (( staged ))    && clean+=$'\033[32m+'"$staged"$'\033[0m '
      (( unstaged ))  && clean+=$'\033[33m!'"$unstaged"$'\033[0m '
      (( untracked )) && clean+=$'\033[34m?'"$untracked"$'\033[0m '
      clean=${clean% }
    else
      clean=$'\033[32m✓ clean\033[0m'
    fi
    local row="${ts}"$'\t'$'\033[36m'"${wt_path}"$'\033[0m '$'\033[33m'"${gsub_branch}"$'\033[0m '"${marker}"' '"${clean}"
    if [[ "$grp" == bottom ]]; then
      rows_bottom+=("$row")
    else
      rows_top+=("$row")
    fi
  done < <(git worktree list)

  # Sort each group latest-first, then stitch with a separator between them.
  local top bottom
  (( ${#rows_top} ))    && top=$(printf '%s\n' "${rows_top[@]}" | sort -rn | cut -f2-)
  (( ${#rows_bottom} )) && bottom=$(printf '%s\n' "${rows_bottom[@]}" | sort -rn | cut -f2-)

  local -a out
  [[ -n "$top" ]] && out+=("$top")
  if [[ -n "$bottom" ]]; then
    [[ -n "$top" ]] && out+=("__SEP__ "$'\033[90m'"──────────── merged ────────────"$'\033[0m')
    out+=("$bottom")
  fi

  local worktree
  worktree=$(printf '%s\n' "${out[@]}" | \
    fzf --ansi --height 80% --layout=reverse \
      --prompt="worktree > " \
      --with-nth=2.. \
      "${preview_opts[@]}" \
      --bind '?:toggle-preview')

  [[ -z "$worktree" ]] && return
  local dir=$(echo "$worktree" | sed 's/\x1b\[[0-9;]*m//g' | awk '{print $1}')
  [[ "$dir" == "__SEP__" || ! -d "$dir" ]] && return
  cd "$dir" || return 1
}
