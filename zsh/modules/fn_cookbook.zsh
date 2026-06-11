# Cookbook Functions: safety, audit, performance, enrichment
# See docs: dotdoctor / brewaudit / pathaudit / zbench / zmodtime / fns

# ============================================================
# 1. SAFETY
# ============================================================

# Scaffold a new script in shellscripts/ with strict-mode header
function new-script() {
  local name="$1"
  if [[ -z "$name" ]]; then
    echo "Usage: new-script <name.sh>"
    return 1
  fi
  [[ "$name" == *.sh ]] || name="${name}.sh"
  local f="$DOTFILES/shellscripts/$name"
  if [[ -e "$f" ]]; then
    echo "exists: $f"
    return 1
  fi
  cat >"$f" <<'EOF'
#!/usr/bin/env bash
# title: TITLE_PLACEHOLDER
set -euo pipefail
IFS=$'\n\t'
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

cleanup() { :; } # remove temp files, kill children here
trap cleanup EXIT INT TERM

main() {
  :
}
main "$@"
EOF
  command sed -i '' "s/TITLE_PLACEHOLDER/${name%.sh}/" "$f" 2>/dev/null ||
    command sed -i "s/TITLE_PLACEHOLDER/${name%.sh}/" "$f"
  chmod +x "$f"
  ${EDITOR:-nvim} "$f"
}

# Confirmation gate for destructive one-liners: confirm && rip build/
function confirm() {
  local msg="${1:-Are you sure?}"
  local reply
  printf '%s [y/N] ' "$msg"
  read -r reply
  [[ "$reply" == [yY]* ]]
}

# Show what a command WILL touch, then ask: dryrun rip *.log
function dryrun() {
  (($# == 0)) && { echo "Usage: dryrun <cmd> [args...]"; return 1; }
  echo "Will run: $*"
  local arg n=0
  for arg in "${@:2}"; do
    [[ -e "$arg" ]] && { printf '  -> %s\n' "$arg"; ((n++)); }
    ((n >= 20)) && { echo "  ... (more)"; break; }
  done
  confirm "Execute?" && "$@"
}

# ============================================================
# 2. AUDIT
# ============================================================

# One command: is this dotfiles repo healthy?
function dotdoctor() {
  local d="${DOTFILES:-$HOME/.dotfiles}"
  local t

  echo "\033[35m== Brewfile drift (used but undeclared) ==\033[0m"
  for t in zoxide atuin direnv sesh eza yazi uv delta dust duf sd hyperfine just; do
    if command -v "$t" >/dev/null 2>&1 && ! grep -q "\"$t\"" "$d/Brewfile"; then
      echo "  ⚠ $t installed but not in Brewfile"
    fi
  done

  echo "\033[35m== Broken symlinks in \$HOME (depth 2) ==\033[0m"
  find ~ -maxdepth 2 -type l ! -exec test -e {} \; -print 2>/dev/null | grep -v "/Library/"

  if command -v shellcheck >/dev/null 2>&1; then
    echo "\033[35m== shellcheck (errors only) ==\033[0m"
    shellcheck -S error "$d"/shellscripts/*.sh 2>/dev/null | head -30
  fi

  if command -v gitleaks >/dev/null 2>&1; then
    echo "\033[35m== Secret scan ==\033[0m"
    gitleaks detect -s "$d" --no-banner --redact 2>&1 | tail -3
  fi

  echo "\033[35m== Largest files tracked in git ==\033[0m"
  git -C "$d" ls-files -z | xargs -0 du -h 2>/dev/null | sort -rh | head -5
}

# Diff live brew state against the Brewfile (both directions)
function brewaudit() {
  local bf="$DOTFILES/Brewfile"
  echo "\033[35m== In Brewfile but not installed ==\033[0m"
  brew bundle check --file="$bf" --verbose | grep -v "^Satisfied" || true
  echo "\033[35m== Installed but not in Brewfile ==\033[0m"
  brew bundle cleanup --file="$bf" 2>/dev/null | head -40
}

# Flag duplicate and dead entries in $PATH
function pathaudit() {
  local -A seen
  local p
  for p in ${(s.:.)PATH}; do
    if [[ -n "${seen[$p]}" ]]; then
      echo "dup : $p"
      continue
    fi
    seen[$p]=1
    [[ -d "$p" ]] || echo "dead: $p"
  done
  echo "total: ${#${(s.:.)PATH}} entries, ${#seen} unique"
}

# ============================================================
# 3. PERFORMANCE
# ============================================================

# Rigorous shell-startup benchmark (statistical, vs timezsh's loop)
function zbench() {
  if ! command -v hyperfine >/dev/null 2>&1; then
    echo "hyperfine not installed: brew install hyperfine"
    return 1
  fi
  hyperfine --warmup 3 'zsh -i -c exit'
}

# A/B benchmark any commands: bench 'rg foo' 'grep -r foo'
function bench() {
  if ! command -v hyperfine >/dev/null 2>&1; then
    echo "hyperfine not installed: brew install hyperfine"
    return 1
  fi
  hyperfine --warmup 2 "$@"
}

# Time each zsh module individually; find the slow one
function zmodtime() {
  local m t
  for m in "$DOTFILES"/zsh/modules/*.zsh; do
    t=$(DOTFILES="$DOTFILES" zsh -fc "
      zmodload zsh/datetime
      typeset -F s=\$EPOCHREALTIME
      source '$m' 2>/dev/null
      printf '%.1f' \$(((EPOCHREALTIME - s) * 1000))
    " 2>/dev/null)
    printf '%7sms  %s\n' "${t:-?}" "${m:t}"
  done | sort -rn
}

# Full startup profile via zprof (uses the ZSH_DEBUGRC hook in zshrc)
function zprofile() {
  ZSH_DEBUGRC=1 zsh -i -c exit
}

# ============================================================
# 4. ENRICHMENT
# ============================================================

# Fuzzy-pick a modified git file (with diff preview) and edit it
function gf() {
  is_git_repo || { echo "Not a git repo"; return 1; }
  local f
  f=$(git status --porcelain | awk '{print $NF}' |
    fzf --prompt='modified > ' \
      --preview 'git diff --color=always -- {} | head -200; git diff --cached --color=always -- {} | head -200' \
      --preview-window=right:60%:wrap) || return
  ${EDITOR:-nvim} "$f"
}

# Fuzzy kill process(es): fkill [signal]  (default TERM)
function fkill() {
  local pids
  pids=$(ps -ef | sed 1d |
    fzf -m --header='TAB to multi-select, ENTER to kill' --prompt='kill > ' |
    awk '{print $2}') || return
  [[ -z "$pids" ]] && return
  echo "$pids" | xargs kill -"${1:-15}"
}

# Browse your own functions with preview; ENTER puts the name on the command line
function fns() {
  local fn
  fn=$(grep -hoE '^(function )?[a-zA-Z0-9_-]+\(\)' "$DOTFILES"/zsh/modules/*.zsh |
    command sed -E 's/^function //; s/\(\)//' | sort -u |
    fzf --prompt='fn > ' \
      --preview "grep -h -A 15 -E '^(function )?{}\(\)' $DOTFILES/zsh/modules/*.zsh | head -30" \
      --preview-window=right:60%:wrap) || return
  print -z "$fn "
}

# Jump to a frecent project: cd + venv + node version in one
function workon() {
  local dir
  dir=$(zoxide query -l 2>/dev/null | fzf --prompt='project > ' \
    --preview 'eza -la --git --no-user {} 2>/dev/null | head -20') || return
  cd "$dir" || return
  [[ -f .venv/bin/activate ]] && source .venv/bin/activate
  [[ -f .nvmrc ]] && command -v fnm >/dev/null 2>&1 && fnm use
}
