# Efficiency Functions - Speed & Productivity
# Focus: Less typing, faster workflow

# ========================================
# Quick Edit & Repeat
# ========================================

# Edit last command in $EDITOR then execute
edit-command-line() {
  local tmpfile=$(mktemp)
  echo "$BUFFER" > "$tmpfile"
  ${EDITOR:-nvim} "$tmpfile"
  BUFFER=$(cat "$tmpfile")
  rm -f "$tmpfile"
  zle redisplay
}
zle -N edit-command-line
bindkey '^x^e' edit-command-line  # Ctrl+X Ctrl+E

# Insert last command's output
insert-last-output() {
  LBUFFER+=$(eval ${history[$((HISTCMD-1))]})
}
zle -N insert-last-output
bindkey '^x^o' insert-last-output  # Ctrl+X Ctrl+O

# ========================================
# Quick Directory Operations
# ========================================

# Quickly go back to previous directory
bindkey -s '^[-' 'cd -\n'  # Alt+-

# Quick bookmark current dir (uses hash)
mark() { hash -d "$1"="$PWD"; echo "Marked: ~$1 -> $PWD" }
# Usage: mark proj → then cd ~proj from anywhere

# ========================================
# Fast Git Operations
# ========================================

# Git status + diff in one view
gsd() { git status -sb && echo "---" && git diff --stat }

# Quick commit with message
gc() { git commit -m "$*" }

# Quick add all + commit
gac() { git add -A && git commit -m "$*" }

# Quick push current branch
gp() { git push origin "$(git branch --show-current)" }

# Amend last commit (no edit)
gam() { git commit --amend --no-edit }

# Interactive rebase last N commits
gri() { git rebase -i HEAD~${1:-5} }

# Stash with message
gss() { git stash push -m "${*:-WIP}" }

# Pop stash by selecting with fzf
gsp() {
  local stash=$(git stash list | fzf --height 40% | cut -d: -f1)
  [[ -n "$stash" ]] && git stash pop "$stash"
}

# ========================================
# Process & System Quick Actions
# ========================================

# Kill process by selecting with fzf
fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m --height 40% | awk '{print $2}')
  [[ -n "$pid" ]] && echo "$pid" | xargs kill -${1:-9}
}

# Port check - what's using a port
port() { lsof -i :$1 }

# Quick HTTP server in current dir
serve() { python3 -m http.server ${1:-8000} }

# ========================================
# File Operations
# ========================================

# Create file with parent directories
touchp() { mkdir -p "$(dirname "$1")" && touch "$1" }

# Backup file with timestamp
bak() { cp "$1" "$1.bak.$(date +%Y%m%d_%H%M%S)" }

# Diff two files side by side (with delta if available)
d() {
  if command -v delta &>/dev/null; then
    delta "$1" "$2"
  else
    diff -y "$1" "$2"
  fi
}

# ========================================
# Quick Search & Navigate
# ========================================

# Ripgrep then open in nvim at line
rgv() {
  local result=$(rg --line-number --color=always "$@" | fzf --ansi --height 50%)
  if [[ -n "$result" ]]; then
    local file=$(echo "$result" | cut -d: -f1)
    local line=$(echo "$result" | cut -d: -f2)
    nvim "+$line" "$file"
  fi
}

# Find and cd to directory containing file
cdf() {
  local file=$(fd --type f "$1" | fzf --height 40%)
  [[ -n "$file" ]] && cd "$(dirname "$file")"
}

# Recent directories with fzf (uses zoxide)
zz() {
  local dir=$(zoxide query -l | fzf --height 40% --tac)
  [[ -n "$dir" ]] && cd "$dir"
}

# ========================================
# Clipboard & Output
# ========================================

# Copy current directory to clipboard
cpwd() {
  if [[ -n "$IS_MAC" ]]; then
    pwd | tr -d '\n' | pbcopy
  else
    pwd | tr -d '\n' | xclip -selection clipboard
  fi
  echo "Copied: $PWD"
}

# Copy file contents to clipboard
cpf() {
  if [[ -n "$IS_MAC" ]]; then
    cat "$1" | pbcopy
  else
    cat "$1" | xclip -selection clipboard
  fi
  echo "Copied contents of: $1"
}

# ========================================
# Key Bindings for Speed
# ========================================

# Ctrl+Z to toggle fg/bg (like vim)
_toggle_fg_bg() {
  if [[ -z $(jobs) ]]; then
    return
  fi
  fg
}
zle -N _toggle_fg_bg
bindkey '^z' _toggle_fg_bg

# Alt+. to insert last argument (already default, but explicit)
bindkey '\e.' insert-last-word

# Ctrl+Q to quote current line and start new command
bindkey '^q' push-line-or-edit

# ========================================
# Advanced ZLE Widgets
# ========================================

# Prepend sudo to current command (Esc Esc)
prepend-sudo() {
  if [[ $BUFFER != sudo\ * ]]; then
    BUFFER="sudo $BUFFER"
    CURSOR=$((CURSOR + 5))
  fi
}
zle -N prepend-sudo
bindkey '\e\e' prepend-sudo  # Esc Esc

# Copy current line to clipboard
copy-line-to-clipboard() {
  if [[ -n "$IS_MAC" ]]; then
    echo -n "$BUFFER" | pbcopy
  else
    echo -n "$BUFFER" | xclip -selection clipboard 2>/dev/null
  fi
  zle -M "Copied to clipboard"
}
zle -N copy-line-to-clipboard
bindkey '^x^c' copy-line-to-clipboard  # Ctrl+X Ctrl+C

# Run git diff without losing current command
widget-git-diff() {
  zle push-line
  BUFFER="git diff --stat"
  zle accept-line
}
zle -N widget-git-diff
bindkey '^x^d' widget-git-diff  # Ctrl+X Ctrl+D

# Run git status without losing current command
widget-git-status() {
  zle push-line
  BUFFER="git status -sb"
  zle accept-line
}
zle -N widget-git-status
bindkey '^x^s' widget-git-status  # Ctrl+X Ctrl+S

# Jump to beginning/end of command arguments (skip first word)
beginning-of-args() {
  zle beginning-of-line
  zle forward-word
}
zle -N beginning-of-args
bindkey '^x^a' beginning-of-args  # Ctrl+X Ctrl+A

# Double Esc in vi mode returns to normal mode and moves to line start
# (handled by zsh-vi-mode plugin)

# ========================================
# Smart Aliases for Common Patterns
# ========================================

# Last command
alias r='fc -s'  # repeat last command
alias rr='fc -s -1'  # repeat second to last

# Quick edits
alias ez='$EDITOR ~/.zshrc && source ~/.zshrc'
alias ea='$EDITOR $DOTFILES/zsh/modules/alias.zsh && source $DOTFILES/zsh/modules/alias.zsh'

# ========================================
# Smart Expansions
# ========================================

# Expand ... to ../.. (already in fn_navigation.zsh)
# This makes typing cd ... expand to cd ../..

# !! expands to last command (built-in)
# !$ expands to last argument of last command (built-in)
# !^ expands to first argument of last command (built-in)
# !* expands to all arguments of last command (built-in)

# ========================================
# Quick Reference (for muscle memory)
# ========================================
# Ctrl+X Ctrl+E  - Edit command in $EDITOR
# Ctrl+X Ctrl+C  - Copy command to clipboard
# Ctrl+X Ctrl+D  - Quick git diff (preserves current line)
# Ctrl+X Ctrl+S  - Quick git status (preserves current line)
# Ctrl+Q         - Push line to stack, type another, then get it back
# Esc Esc        - Prepend sudo
# Alt+.          - Insert last argument
# Alt+-          - cd to previous dir
# Ctrl+Z         - Toggle fg/bg
