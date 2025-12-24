# Navigation & File Manager Functions

# Yazi file manager with directory changing
function ya() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# lf file manager with directory changing
function lfcd() {
  tmp="$(mktemp)"
  command lf -last-dir-path="$tmp" "$@"
  if [ -f "$tmp" ]; then
    dir="$(cat "$tmp")"
    rm -f "$tmp"
    if [ -d "$dir" ]; then
      if [ "$dir" != "$(pwd)" ]; then
        cd "$dir"
      fi
    fi
  fi
}

# joshuto file manager
function joshuto_official() {
  ID="$$"
  mkdir -p /tmp/$USER
  OUTPUT_FILE="/tmp/$USER/joshuto-cwd-$ID"
  env joshuto --output-file "$OUTPUT_FILE" $@
  exit_code=$?
  case "$exit_code" in
    0) ;;
    101)
      JOSHUTO_CWD=$(cat "$OUTPUT_FILE")
      cd "$JOSHUTO_CWD"
      ;;
    102) ;;
    *) echo "Exit code: $exit_code" ;;
  esac
}

# Fuzzy cd with fd
fcd() {
  local dir
  dir=$(fd --type d | fzf) && cd "$dir"
}

# Fuzzy cd with find
function cdf() {
  DIR=$(find * -type d | fzf)
  if [ -n "$DIR" ]; then
    cd $DIR
  else
    echo "千裡之行，始於足下"
  fi
}

# Make directory and cd into it
function mkcd() {
  mkdir -p "$@" && cd "$_"
}

# Jump up N directories (e.g., `up 3` = cd ../../..)
up() {
  local d=""
  local limit="${1:-1}"
  for ((i = 1; i <= limit; i++)); do
    d="../$d"
  done
  d="${d%/}"
  [[ -z "$d" ]] && d=".."
  cd "$d" || return 1
}

# Go to git repository root
function gitop() {
  if git rev-parse --show-toplevel >/dev/null 2>&1; then
    cd "$(git rev-parse --show-toplevel)"
  else
    echo "\033[31mNot in a git repository\033[0m"
  fi
}

# Create ./YYYY-MM-DD directory and cd into it
mkymd() {
  emulate -L zsh
  setopt localoptions no_unset
  local d dir
  d="$(date +%F)"
  dir="./${d}"
  mkdir -p -- "$dir" || return $?
  cd -- "$dir"
}

# chpwd hook - runs on directory change
function chpwd() {
  echo "你現在在 $(pwd)"
  # macOS only - auto-ignore common directories in Dropbox
  if [[ -n "$IS_MAC" ]]; then
    for dir in .venv node_modules; do
      if [[ -d $dir ]]; then
        xattr -w 'com.apple.fileprovider.ignore#P' 1 "$dir"
      fi
    done
  fi
}

# Rationalize dots: ... → ../.. automatically
rationalize-dot() {
  if [[ $LBUFFER = *.. ]]; then
    LBUFFER+=/..
  else
    LBUFFER+=.
  fi
}
zle -N rationalize-dot
bindkey . rationalize-dot
bindkey -M isearch . self-insert
