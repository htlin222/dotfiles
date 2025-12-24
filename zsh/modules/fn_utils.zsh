# Miscellaneous Utility Functions

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
    *.tar.gz)  tar xzf "$1" ;;
    *.tar.xz)  tar xJf "$1" ;;
    *.tar.zst) tar --zstd -xf "$1" ;;
    *.bz2)     bunzip2 "$1" ;;
    *.rar)     unrar x "$1" ;;
    *.gz)      gunzip "$1" ;;
    *.tar)     tar xf "$1" ;;
    *.tbz2)    tar xjf "$1" ;;
    *.tgz)     tar xzf "$1" ;;
    *.zip)     unzip "$1" ;;
    *.Z)       uncompress "$1" ;;
    *.7z)      7z x "$1" ;;
    *.deb)     ar x "$1" ;;
    *.xz)      unxz "$1" ;;
    *.lzma)    unlzma "$1" ;;
    *)         echo "'$1' cannot be extracted via ex()" ;;
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
  xdg-open "$1" &>/dev/null &
}

# tre with aliases
function tre() { command tre "$@" -e && source "/tmp/tre_aliases_$USER" 2>/dev/null; }

# Undelete file from trash
function undelfile() {
  mv -i ~/.Trash/files/$@ ./
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
      mod_date=$(date -r "$file" +"%Y-%m-%d")
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
