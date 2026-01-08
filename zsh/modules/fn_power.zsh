# Power User Features - Advanced Efficiency
# Fish-style abbreviations, fzf integrations, smart shortcuts

# ========================================
# Fish-style Abbreviations (Auto-expand)
# ========================================
# Type abbreviation + Space → expands automatically
# Use Ctrl+Space to insert literal space without expansion

typeset -A abbreviations
abbreviations=(
  "g"     "git"
  "ga"    "git add"
  "gaa"   "git add -A"
  "gb"    "git branch"
  "gco"   "git checkout"
  "gcm"   "git commit -m"
  "gd"    "git diff"
  "gf"    "git fetch"
  "gl"    "git log --oneline"
  "gpl"   "git pull"
  "gps"   "git push"
  "gst"   "git status -sb"
  "grb"   "git rebase"
  "grs"   "git reset"
  "gsh"   "git stash"
  "k"     "kubectl"
  "kgp"   "kubectl get pods"
  "kgs"   "kubectl get svc"
  "kgd"   "kubectl get deployments"
  "kl"    "kubectl logs"
  "ke"    "kubectl exec -it"
  "dc"    "docker compose"
  "dps"   "docker ps"
  "di"    "docker images"
  "drm"   "docker rm"
  "dri"   "docker rmi"
  "tx"    "tmux"
  "txa"   "tmux attach -t"
  "txn"   "tmux new -s"
  "txl"   "tmux list-sessions"
  "txk"   "tmux kill-session -t"
  "py"    "python3"
  "ipy"   "ipython"
  "nv"    "nvim"
  "lg"    "lazygit"
  "ld"    "lazydocker"
)

_expand_abbreviation() {
  local MATCH
  LBUFFER=${LBUFFER%%(#m)[._a-zA-Z0-9]#}
  local abbr=${abbreviations[$MATCH]}
  LBUFFER+=${abbr:-$MATCH}
  zle self-insert
}
zle -N _expand_abbreviation

# Space expands abbreviations
bindkey ' ' _expand_abbreviation
# Ctrl+Space inserts literal space
bindkey '^ ' self-insert

# ========================================
# FZF Git Integration (Ctrl+G prefix)
# ========================================

# Ctrl+G Ctrl+B - Git branches
fzf-git-branch() {
  local branch=$(git branch -a --color=always | grep -v HEAD |
    fzf --ansi --height 40% --reverse --tac |
    sed 's/^[ *]*//' | sed 's#remotes/origin/##')
  if [[ -n "$branch" ]]; then
    LBUFFER+="$branch"
  fi
  zle redisplay
}
zle -N fzf-git-branch
bindkey '^g^b' fzf-git-branch

# Ctrl+G Ctrl+H - Git commit hashes
fzf-git-hash() {
  local hash=$(git log --oneline --color=always |
    fzf --ansi --height 50% --reverse --preview 'git show --color=always {1}' |
    awk '{print $1}')
  if [[ -n "$hash" ]]; then
    LBUFFER+="$hash"
  fi
  zle redisplay
}
zle -N fzf-git-hash
bindkey '^g^h' fzf-git-hash

# Ctrl+G Ctrl+F - Git changed files
fzf-git-file() {
  local file=$(git status -s | fzf --height 40% --reverse | awk '{print $2}')
  if [[ -n "$file" ]]; then
    LBUFFER+="$file"
  fi
  zle redisplay
}
zle -N fzf-git-file
bindkey '^g^f' fzf-git-file

# Ctrl+G Ctrl+T - Git tags
fzf-git-tag() {
  local tag=$(git tag --sort=-version:refname |
    fzf --height 40% --reverse --preview 'git show --color=always {}')
  if [[ -n "$tag" ]]; then
    LBUFFER+="$tag"
  fi
  zle redisplay
}
zle -N fzf-git-tag
bindkey '^g^t' fzf-git-tag

# ========================================
# FZF Docker Integration
# ========================================

# Select and attach to running container
datt() {
  local cid=$(docker ps | sed 1d | fzf --height 40% -q "$1" | awk '{print $1}')
  [[ -n "$cid" ]] && docker exec -it "$cid" "${2:-/bin/sh}"
}

# Select and stop container
dstop() {
  local cid=$(docker ps | sed 1d | fzf -m --height 40% | awk '{print $1}')
  [[ -n "$cid" ]] && echo "$cid" | xargs docker stop
}

# Select and remove container
drmf() {
  local cid=$(docker ps -a | sed 1d | fzf -m --height 40% | awk '{print $1}')
  [[ -n "$cid" ]] && echo "$cid" | xargs docker rm -f
}

# Select and remove image
drmif() {
  local iid=$(docker images | sed 1d | fzf -m --height 40% | awk '{print $3}')
  [[ -n "$iid" ]] && echo "$iid" | xargs docker rmi -f
}

# Docker logs with fzf
dlogs() {
  local cid=$(docker ps | sed 1d | fzf --height 40% | awk '{print $1}')
  [[ -n "$cid" ]] && docker logs -f "$cid"
}

# ========================================
# FZF Tmux Integration
# ========================================

# Switch tmux session
ts() {
  [[ -z "$TMUX" ]] && { echo "Not in tmux"; return 1; }
  local session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null |
    fzf --height 40% --reverse)
  [[ -n "$session" ]] && tmux switch-client -t "$session"
}

# Kill tmux session
tk() {
  local session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null |
    fzf -m --height 40% --reverse)
  [[ -n "$session" ]] && echo "$session" | xargs -I{} tmux kill-session -t {}
}

# ========================================
# Smart Path Expansion
# ========================================

# Expand ~~ to project root (git root or home)
_expand_tilde_tilde() {
  if [[ $LBUFFER == *"~~"* ]]; then
    local root=$(git rev-parse --show-toplevel 2>/dev/null || echo $HOME)
    LBUFFER=${LBUFFER//\~\~/$root}
  fi
  zle self-insert
}
# (disabled - conflicts with other bindings)

# ========================================
# Quick Commands
# ========================================

# Repeat last command with modifications
# Usage: redo s/old/new/
redo() {
  local last=$(fc -ln -1)
  if [[ -n "$1" ]]; then
    eval "${last} | sed '$1'"
  else
    eval "$last"
  fi
}

# Run command N times
# Usage: times 5 echo hello
times() {
  local n=$1; shift
  for ((i=1; i<=n; i++)); do "$@"; done
}

# Watch command with 1s interval (shorter than default 2s)
w1() { watch -n 1 "$@"; }

# ========================================
# Quick Navigation Widgets
# ========================================

# Ctrl+G Ctrl+R - cd to git root
widget-cd-git-root() {
  local root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ -n "$root" ]]; then
    cd "$root"
    zle reset-prompt
  fi
}
zle -N widget-cd-git-root
bindkey '^g^r' widget-cd-git-root

# ========================================
# Performance: Lazy-load heavy completions
# ========================================

# Lazy kubectl completion
if command -v kubectl &>/dev/null; then
  kubectl() {
    unfunction kubectl
    source <(command kubectl completion zsh)
    command kubectl "$@"
  }
fi

# Lazy helm completion
if command -v helm &>/dev/null; then
  helm() {
    unfunction helm
    source <(command helm completion zsh)
    command helm "$@"
  }
fi

# ========================================
# Quick Reference
# ========================================
# ABBREVIATIONS (type + Space to expand):
#   g→git  ga→git add  gco→git checkout  k→kubectl  dc→docker compose
#
# FZF GIT (Ctrl+G prefix):
#   Ctrl+G Ctrl+B  - Select branch
#   Ctrl+G Ctrl+H  - Select commit hash
#   Ctrl+G Ctrl+F  - Select changed file
#   Ctrl+G Ctrl+T  - Select tag
#   Ctrl+G Ctrl+R  - cd to git root
#
# FZF DOCKER:
#   datt   - Attach to container
#   dstop  - Stop container(s)
#   drmf   - Remove container(s)
#   dlogs  - Tail container logs
#
# FZF TMUX:
#   ts     - Switch session
#   tk     - Kill session(s)
