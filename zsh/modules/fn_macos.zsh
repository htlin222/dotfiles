# macOS Specific Functions
# These functions only work on macOS

# Remove quarantine from apps
function unlock() {
  if [[ -z "$IS_MAC" ]]; then
    echo "unlock: This function is macOS only"
    return 1
  fi
  sh "$DOTFILES/shellscripts/do_not_block_app.sh"
}

# Remove quarantine attribute
function unblock() {
  if [[ -z "$IS_MAC" ]]; then
    echo "unblock: This function is macOS only"
    return 1
  fi
  sudo xattr -r -d com.apple.quarantine "$@"
}

# Remove Homebrew cask
function brewforget() {
  if [[ -z "$IS_MAC" ]]; then
    echo "brewforget: This function is macOS only"
    return 1
  fi
  rm "/opt/homebrew/Caskroom/$@"
}

# Ignore Dropbox file
ignore_dropbox_file() {
  if [[ -z "$IS_MAC" ]]; then
    echo "ignore_dropbox_file: This function is macOS only"
    return 1
  fi
  local filepath
  filepath=$(find "$HOME/Library/CloudStorage/Dropbox" -type f | fzf)
  [ -n "$filepath" ] && xattr -w 'com.apple.fileprovider.ignore#P' 1 "$filepath"
}

# Ignore Dropbox folder
ignore_dropbox_folder() {
  if [[ -z "$IS_MAC" ]]; then
    echo "ignore_dropbox_folder: This function is macOS only"
    return 1
  fi
  local folderpath
  echo "🔍 選擇要忽略的 Dropbox 資料夾..."
  folderpath=$(find "$HOME/Library/CloudStorage/Dropbox" -type d | fzf)
  if [ -n "$folderpath" ]; then
    xattr -w 'com.apple.fileprovider.ignore#P' 1 "$folderpath"
    echo "✅ 成功忽略：$folderpath"
  else
    echo "❌ 未選擇資料夾"
  fi
}

# Download iCloud files
function icdn() {
  GREEN="\033[32m"
  RESET="\033[0m"
  echo "The following files are in the cloud nine:"
  find . -name '.*icloud'
  find . -name '.*icloud' | perl -pe 's|(.*)/.(.*).icloud|$1/$2|s' | while read file; do brctl download "$file"; done
  echo "\n${GREEN}Start to download all the files, be patient! ⏱️ ${RESET}"
}

# Download iCloud file or folder
function icloudownload() {
  if ! command -v find >/dev/null; then
    echo "❌ 'find' is not installed. Please install it first."
    return 1
  fi
  if [[ -z "$1" ]]; then
    echo "📂 Usage: icloudownload /path/to/icloud/file_or_folder"
    return 1
  fi
  local target="$1"
  if [[ -f "$target" ]]; then
    local size=$(stat -f%z "$target")
    echo -ne "📄 [1/1] Processing: $target (${size} bytes) \r"
    head -c 1 "$target" > /dev/null
    echo -e "✅ Done: $target (${size} bytes)                    "
  elif [[ -d "$target" ]]; then
    local IFS=$'\n'
    local files=($(find "$target" -type f))
    local total=${#files[@]}
    local count=0
    for file in "${files[@]}"; do
      ((count++))
      local size=$(stat -f%z "$file")
      echo -ne "📄 [$count/$total] Processing: $file (${size} bytes) \r"
      head -c 1 "$file" > /dev/null
    done
    echo -e "\n✅ Folder download complete: $target ($total files)"
  else
    echo "❌ '$target' is not a valid file or folder."
    return 1
  fi
}

# Reload iCloud sync
function reloadiCloud() {
  killall bird
  killall cloudd
}

# Add reminder (requires reminders-cli)
remind() {
  if ! command -v reminders >/dev/null 2>&1; then
    echo "reminders 未安裝" >&2
    return 1
  fi
  local list=${3:-Inbox}
  reminders add "$list" "$1" --due-date "$2"
}
