# Miscellaneous Utility Functions

# Mobile mode toggle
export ISMOBILE=false
mobile() {
  if [[ "$ISMOBILE" == "true" ]]; then
    export ISMOBILE=false
    [[ -n "$TMUX" ]] && tmux set -g @ismobile off
  else
    export ISMOBILE=true
    [[ -n "$TMUX" ]] && tmux set -g @ismobile on
  fi
  echo "ISMOBILE=$ISMOBILE"
}

# Cross-platform notification
function notify() {
  local title="$1"
  local content="$2"
  if [[ -n "$IS_MAC" ]]; then
    osascript -e "display notification \"$content\" with title \"$title\""
  elif command -v notify-send &>/dev/null; then
    notify-send "$title" "$content"
  else
    echo "[$title] $content"
  fi
}

# Benchmark zsh startup
function timezsh() {
  shell=${1-$SHELL}
  for i in $(seq 1 4); do /usr/bin/time $shell -i -c exit; done
}

# Convert files to PDF
topdf() {
  if [ $# -eq 0 ]; then
    echo "Usage: convert_to_pdf <file1> [file2 ...]"
    return 1
  fi
  for file in "$@"; do
    if [ -f "$file" ]; then
      soffice --headless --convert-to pdf "$file"
      echo "Converted $file to PDF."
    else
      echo "File $file not found."
    fi
  done
}

# Universal extract
ex() {
  if [[ -z "$1" ]]; then
    echo "Usage: ex <archive>"
    return 1
  fi
  if [[ ! -f "$1" ]]; then
    echo "'$1' is not a valid file"
    return 1
  fi
  case "$1" in
  *.tar.bz2) tar xjf "$1" ;;
  *.tar.gz) tar xzf "$1" ;;
  *.tar.xz) tar xJf "$1" ;;
  *.tar.zst) tar --zstd -xf "$1" ;;
  *.bz2) bunzip2 "$1" ;;
  *.rar) unrar x "$1" ;;
  *.gz) gunzip "$1" ;;
  *.tar) tar xf "$1" ;;
  *.tbz2) tar xjf "$1" ;;
  *.tgz) tar xzf "$1" ;;
  *.zip) unzip "$1" ;;
  *.Z) uncompress "$1" ;;
  *.7z) 7z x "$1" ;;
  *.deb) ar x "$1" ;;
  *.xz) unxz "$1" ;;
  *.lzma) unlzma "$1" ;;
  *) echo "'$1' cannot be extracted via ex()" ;;
  esac
}

# Swap two filenames
swap() {
  if [[ $# -ne 2 ]]; then
    echo "Usage: swap <file1> <file2>"
    return 1
  fi
  local tmp="tmp.$$"
  mv "$1" "$tmp" && mv "$2" "$1" && mv "$tmp" "$2"
}

# Rename files removing brackets
function rename_in_sqb() {
  for file in *[*]*.txt; do
    newname=$(echo "$file" | sed -E 's/\[[^]]*\]//g')
    mv "$file" "$newname"
  done
}

# xdg-open in background
function xdgopen() {
  if command -v xdg-open &>/dev/null; then
    xdg-open "$1" &>/dev/null &
  elif command -v open &>/dev/null; then
    open "$1" &>/dev/null &
  elif command -v gio &>/dev/null; then
    gio open "$1" &>/dev/null &
  else
    echo "No open command found (xdg-open/open/gio)" >&2
    return 127
  fi
}

# tre with aliases
function tre() { command tre "$@" -e && source "/tmp/tre_aliases_$USER" 2>/dev/null; }

# Undelete file from trash
function undelfile() {
  if [[ -n "$IS_MAC" ]]; then
    mv -i ~/.Trash/files/"$@" ./
  elif command -v gio &>/dev/null; then
    gio trash --restore "$@"
  else
    echo "Trash restore not supported on this OS" >&2
    return 1
  fi
}

# Marp slide server
function check_and_start_marp_serve() {
  if pgrep -f "marp .+ -s" >/dev/null; then
    echo "Marp serve is already running in the background."
  else
    echo "Starting Marp serve..."
    SLIDES="$HOME/Dropbox/slides"
    marp "$SLIDES/contents/" -s \
      -c "$SLIDES/package.json" \
      "$@" &
  fi
}

function killmarp() {
  pkill -f marp
}

# Force-exit a mosh session by killing its mosh-server ancestor.
# Avoids the hang caused by mosh's UDP state-sync teardown on `exit`.
# Walks up the process tree so only the current session's server dies.
mosh-bye() {
  emulate -L zsh
  local pid=$$ server="" comm ppid
  while (( pid > 1 )); do
    comm=$(ps -o comm= -p $pid 2>/dev/null)
    [[ $comm == mosh-server ]] && { server=$pid; break }
    ppid=$(ps -o ppid= -p $pid 2>/dev/null | tr -d ' ')
    [[ -z $ppid || $ppid == $pid ]] && break
    pid=$ppid
  done

  if [[ -n $server ]]; then
    print -u2 "mosh-bye: terminating mosh-server (PID $server)"
    kill -TERM "$server" 2>/dev/null || kill -KILL "$server"
  else
    print -u2 "mosh-bye: no mosh-server ancestor found; falling back to exit"
    exit
  fi
}

# Make slide executable and present
function make_exec_and_slide() {
  cd $HOME/Dropbox/slides/contents
  file=$(find . -type f -name "*.md" | sed 's|^\./||' | fzf-pre)
  chmod +x "$file"
  slides "$file"
}

# Generate Medium OG image
function mediumog() {
  if [ $# -eq 0 ]; then
    echo "Usage: mediumog <slide_name>"
    return 1
  fi
  local slide_name="$1"
  sh ~/.dotfiles/shellscripts/gen_medium_og.sh "$slide_name"
}

# Organize files by date
chore() {
  for file in *; do
    if [[ -f "$file" && ! -L "$file" ]]; then
      if [[ -n "$IS_MAC" ]]; then
        mod_date=$(date -r "$file" +"%Y-%m-%d")
      else
        mod_date=$(date -d "@$(stat -c %Y "$file")" +"%Y-%m-%d")
      fi
      if [[ ! "$file" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}_ ]]; then
        filename_no_ext="${file%.*}"
        new_folder="${mod_date}_${filename_no_ext}"
        mkdir -p "$new_folder"
        mv "$file" "$new_folder/"
        echo "Moved $file to $new_folder/"
      else
        echo "$file already starts with a date, skipping."
      fi
    elif [[ -L "$file" ]]; then
      echo "$file is a symlink, skipping."
    fi
  done
}

# Sync quarto files
syncq() {
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  NC='\033[0m'

  printf "${YELLOW}Are you sure you want to sync the files? (y/n)${NC} "
  read confirm
  if [ "$confirm" = "y" ]; then
    printf "${GREEN}Syncing files...${NC}\n"
    rsync -av --exclude '.*' "$HOME/quarto-revealjs-starter/_extensions" "$HOME/quarto-revealjs-starter/assets" "$HOME/quarto-revealjs-starter/_quarto.yml" ./
    printf "${GREEN}Sync complete.${NC}\n"
  else
    printf "${RED}Sync canceled.${NC}\n"
  fi
}

# Detect RSS feeds
findfeed() {
  if [ -z "$1" ]; then
    echo "Usage: findfeed <url>"
    return 1
  fi
  curl -s "$1" | grep -Eoi '<link[^>]+(rss|atom|xml)[^>]*>' | sed 's/.*href=["'\'']\([^"'\'' ]*\).*/\1/'
}

# Get remote host for LAN sync (auto-detect peer device)
_get_lan_peer() {
  local HOST_A="192.168.0.219"
  local HOST_B="192.168.0.222"
  local my_ip=""
  if [[ -n "$IS_MAC" ]]; then
    my_ip=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null)
  elif command -v ip &>/dev/null; then
    my_ip=$(ip -o -4 addr show scope global | awk '{print $4}' | cut -d/ -f1 | head -n1)
  elif command -v hostname &>/dev/null; then
    my_ip=$(hostname -I 2>/dev/null | awk '{print $1}')
  fi

  if [[ "$my_ip" == "$HOST_A" ]]; then
    echo "$HOST_B"
  elif [[ "$my_ip" == "$HOST_B" ]]; then
    echo "$HOST_A"
  else
    echo ""
  fi
}

# Push files to LAN peer device via rsync over SSH
# Usage: pushto <local_path> [remote_path]
# Examples:
#   pushto ./file.txt              # Push to remote home dir
#   pushto ./mydir/                # Push directory
#   pushto ./file.txt ~/Documents/ # Push to specific remote path
pushto() {
  local REMOTE_HOST="$(_get_lan_peer)"
  local REMOTE_USER="$(whoami)"
  local REMOTE_BASE="/Users/${REMOTE_USER}"

  if [[ -z "$REMOTE_HOST" ]]; then
    echo "Error: Not on a known LAN host (192.168.0.219 or 192.168.0.222)"
    return 1
  fi

  if [[ $# -lt 1 ]]; then
    echo "Usage: pushto <local_path> [remote_path]"
    echo "  local_path:  file or directory to push"
    echo "  remote_path: destination on remote (default: ~)"
    return 1
  fi

  local src="$1"
  local dest="${2:-$REMOTE_BASE}"

  # Expand ~ in dest
  [[ "$dest" == "~"* ]] && dest="${dest/#\~/$REMOTE_BASE}"

  if [[ ! -e "$src" ]]; then
    echo "Error: '$src' does not exist"
    return 1
  fi

  echo "Pushing: $src → ${REMOTE_USER}@${REMOTE_HOST}:${dest}"
  rsync -avz --progress "$src" "${REMOTE_USER}@${REMOTE_HOST}:${dest}"
}

# Pull files from LAN peer device via rsync over SSH
# Usage: pullfrom <remote_path> [local_path]
pullfrom() {
  local REMOTE_HOST="$(_get_lan_peer)"
  local REMOTE_USER="$(whoami)"
  local REMOTE_BASE="/Users/${REMOTE_USER}"

  if [[ -z "$REMOTE_HOST" ]]; then
    echo "Error: Not on a known LAN host (192.168.0.219 or 192.168.0.222)"
    return 1
  fi

  if [[ $# -lt 1 ]]; then
    echo "Usage: pullfrom <remote_path> [local_path]"
    echo "  remote_path: file or directory on remote"
    echo "  local_path:  destination locally (default: ./)"
    return 1
  fi

  local src="$1"
  local dest="${2:-.}"

  # Expand ~ in src
  [[ "$src" == "~"* ]] && src="${src/#\~/$REMOTE_BASE}"

  echo "Pulling: ${REMOTE_USER}@${REMOTE_HOST}:${src} → $dest"
  rsync -avz --progress "${REMOTE_USER}@${REMOTE_HOST}:${src}" "$dest"
}

line() {
  local query=""
  local yank=false

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
    --yank | -y)
      yank=true
      ;;
    *)
      query="$1"
      ;;
    esac
    shift
  done

  local result
  result=$(rg -n --color=always . 2>/dev/null | fzf \
    --ansi \
    --query="$query" \
    --delimiter=: \
    --preview='bat --color=always --style=numbers,header --highlight-line {2} -- {1} 2>/dev/null || cat -n {1}' \
    --preview-window='right:60%:+{2}-10' \
    --bind='j:down,k:up' \
    --header="Type to search  |  Enter: $(if $yank; then echo 'yank'; else echo 'open'; fi)  |  Esc: cancel")

  [[ -z "$result" ]] && return

  local file line content fullpath
  file=$(echo "$result" | cut -d: -f1)
  line=$(echo "$result" | cut -d: -f2)
  content=$(echo "$result" | cut -d: -f3-)
  fullpath="$(pwd)/${file}"

  if [[ -n "$file" ]]; then
    if $yank; then
      if command -v pbcopy &>/dev/null; then
        printf "%s:%s\n%s" "@${fullpath}" " See Line${line}:" "${content}" | pbcopy
        echo "Copied: ${fullpath}:${line}"
        echo "${content}"
      else
        echo "pbcopy not available; printing content instead:" >&2
        printf "%s:%s\n%s\n" "@${fullpath}" " See Line${line}:" "${content}"
      fi
    else
      nvim "+$line" "$file"
    fi
  fi
}

claudetmux() {
  local slug
  slug="claude-$(openssl rand -hex 3)"
  tmux new-session -d -s "$slug" 'claude --dangerously-skip-permissions'
  tmux attach -t "$slug"
}

codextmux() {
  local slug
  slug="codex-$(openssl rand -hex 3)"
  tmux new-session -d -s "$slug" 'codex --yolo'
  tmux attach -t "$slug"
}

# Push the local terminal's terminfo to a remote host so tput/clear/vim/tmux
# stop complaining `unknown terminal "$TERM"` over SSH. Sends ONLY the one
# terminfo definition (via infocmp | tic) into the remote's ~/.terminfo — no
# need to install the whole terminal emulator there. Common with Ghostty,
# WezTerm, kitty, Alacritty whose TERM isn't in older remote terminfo dbs.
#   fix-ghostty-term casey@host          # fixes current $TERM (e.g. xterm-ghostty)
#   fix-ghostty-term casey@host wezterm  # fix a specific terminfo entry
fix-ghostty-term() {
  local host="$1"
  local term="${2:-$TERM}"
  if [[ -z "$host" ]]; then
    echo "usage: fix-ghostty-term <user@host> [term=\$TERM]" >&2
    return 1
  fi
  if ! infocmp -x "$term" >/dev/null 2>&1; then
    echo "fix-ghostty-term: no local terminfo for '$term' (nothing to send)" >&2
    return 1
  fi
  # The 'older tic versions may treat the description field as an alias' notice
  # is a harmless warning, not a failure — the entry still installs.
  if infocmp -x "$term" | ssh "$host" -- tic -x -; then
    echo "✓ '$term' terminfo installed on $host — reconnect to verify (tput colors)"
  else
    echo "fix-ghostty-term: failed to install '$term' on $host" >&2
    return 1
  fi
}

# Break all panes in current tmux window into separate windows
break_panes() {
  if [[ -z "$TMUX" ]]; then
    echo "Not in a tmux session."
    return 1
  fi
  local session win panes new_panes
  session=$(tmux display-message -p '#S')
  win=$(tmux display-message -p '#I')
  panes=$(tmux list-panes -t "${session}:${win}" | wc -l | tr -d ' ')
  if (( panes <= 1 )); then
    echo "Only 1 pane, nothing to break."
    return 0
  fi
  while (( panes > 1 )); do
    tmux break-pane -d -s "${session}:${win}.1" 2>/dev/null || break
    new_panes=$(tmux list-panes -t "${session}:${win}" | wc -l | tr -d ' ')
    (( new_panes >= panes )) && break
    panes=$new_panes
  done
  echo "Done. Broke into separate windows."
}
alias bp='break_panes'

# Parse the bare target host/alias from an ssh(1) argv. Returns it on stdout
# (empty if argv has only flags). Skips options that take a value, strips a
# user@ prefix and a :port / trailing suffix. Unit-tested in zsh/tests/.
_ssh_target_from_args() {
  local target="" arg
  local -a takes_arg=(-b -c -D -E -e -F -I -i -J -L -l -m -O -o -p -Q -R -S -W -w)
  local skip_next=0
  for arg in "$@"; do
    if (( skip_next )); then skip_next=0; continue; fi
    if [[ "$arg" == -* ]]; then
      (( ${takes_arg[(I)$arg]} )) && skip_next=1
      continue
    fi
    target="$arg"; break
  done
  target="${target##*@}"; target="${target%%:*}"
  print -r -- "$target"
}

# ssh wrapper — set the terminal/tab title to the SSH target so it shows even
# when the remote host has no title hook. The remote shell (if it runs the
# _set_term_title precmd from these dotfiles) refines it to its own %m, and on
# exit the local precmd restores the local hostname. Doubly robust.
ssh() {
  local target; target="$(_ssh_target_from_args "$@")"
  [[ -n "$target" ]] && print -Pn "\e]0;${target}\a"
  command ssh "$@"
  print -Pn '\e]0;%m\a'   # restore local hostname after the session ends
}
