# Note-taking & Writing Functions

# Search and edit markdown files in Dropbox
function hh() {
  cd ~/Dropbox/
  (python3 ~/Dropbox/scripts/gen_recent_list.py &)
  FILE=$(find . -type f -name "*.md" | sed 's|^\./||' | fzf-pre)
  if [ -n "$FILE" ]; then
    nvim +10 "$FILE"
  else
    cd ~/Dropbox/Medical/
    echo "獨學而無友，則孤陋而寡聞"
  fi
}

# Study medical notes
function study() {
  cd ~/Dropbox/Medical/
  (python3 ~/Dropbox/scripts/gen_recent_list.py &)
  FILE=$(find . -type f -name "*.md" | sed 's|^\./||' | fzf-pre)
  if [ -n "$FILE" ]; then
    nvim +10 "$FILE"
  else
    echo "獨學而無友，則孤陋而寡聞"
  fi
}

# Study with ripgrep
function studyrg() {
  cd ~/Dropbox/Medical/
  rgnv
}

# Recent notes
function recent_note() {
  cd ~/Dropbox/Medical/
  file=$(ls -lt | head -n 30 | awk '{print $NF}' | fzf --preview 'bat --style=numbers --color=always {}')
  [ -n "$file" ] && vim "$file"
}

# Daily diary
function dia() {
  (python3 ~/pyscripts/inbox.py &)
  local filename="$HOME/Dropbox/inbox/$(date +"%Y-%m-%d").md"
  if [ -e "$filename" ]; then
    nvim +13 "$filename"
  else
    {
      echo "---"
      echo "title: \"$(date +"%Y-%m-%d")\""
      echo "date: \"$(date +"%Y-%m-%d")\""
      echo "enableToc: false"
      echo "tags:"
      echo "  - diary"
      echo "---"
      echo ""
      echo "> back to [[index]]"
      echo "> go to [[todo_list]]"
      echo ""
      echo "<$(date +"%Y-%m-%d")>"
      echo ""
      echo ""
      echo "---"
    } >>"$filename"
    nvim +13 "$filename"
  fi
}

# Blog drafts
function drafts() {
  cd ~/Dropbox/blog/
  FILE=$(find . -type f -name "*.md" | sed 's|^\./||' | fzf)
  if [ -n "$FILE" ]; then
    nvim +8 "$FILE"
  else
    echo "Do you want to create a new draft? [y/n]"
    read answer
    if [[ $answer == "y" ]]; then
      draft
    else
      echo "一隻鳥接著一隻鳥寫就對了！"
    fi
  fi
}

# New blog draft
function draft() {
  cd "$HOME/Dropbox/blog/"
  local filename="$HOME/Dropbox/blog/$(date +"%Y-%m-%d-%H-%M").md"
  if [ -e "$filename" ]; then
    nvim +10 "$filename"
  else
    {
      echo "---"
      echo "title: \"$(date +"%Y-%m-%d")\""
      echo "date: \"$(date -u +"%Y-%m-%d")\""
      echo "author: \"林協霆\""
      echo "template: post"
      echo "draft: true"
      echo "description: \"這個人很懶不寫介紹\""
      echo "category: tutorial"
      echo "---"
      echo ""
      echo ""
      echo "## Fleet"
    } >>"$filename"
    nvim +10 "$filename"
  fi
}

# Add note from clipboard
function note() {
  cd ~/Dropbox/Medical/
  if ! command -v pbpaste &>/dev/null; then
    echo "pbpaste not available" >&2
    return 127
  fi
  content=$(pbpaste)
  title="\n## Note: $(date +"%Y-%m-%d %H:%M")\n"
  content_with_title="$title$content"
  filename=$(fzf-pre)
  echo -e "$content_with_title" >>"$filename"
  vim $filename
}

# Inbox
function inbox() {
  cd ~/Dropbox/inbox/
  python3 ~/pyscripts/inbox.py
  nvim +10 ~/Dropbox/inbox/index.md
}

# Anki flashcard creation
function anki() {
  local anki_dir="${ANKI_DIR:-$HOME/anki}"
  local filename="$(date +%Y%m%d).md"
  local filepath="$anki_dir/$filename"
  local date_formatted="$(date +%Y%m%d)"

  if [[ ! -d "$anki_dir" ]]; then
    mkdir -p "$anki_dir" || { echo "Error: Failed to create directory $anki_dir" >&2; return 1; }
  fi
  if ! command -v nvim >/dev/null 2>&1; then
    echo "Error: nvim not found in PATH" >&2
    return 1
  fi
  if [[ ! -f "$filepath" ]]; then
    {
      echo "# 00_Inbox "
      echo ""
      echo "## Subdeck: $date_formatted"
      echo ""
      echo "### "
    } > "$filepath" || { echo "Error: Failed to create file $filepath" >&2; return 1; }
    echo "Created new anki file: $filepath"
  fi
  nvim + "$filepath"
}

# Patients notes
function patients() {
  cd ~/Dropbox/patients/
  nvim "$(find . -type f -name "*.md" | sed 's|^\./||' | fzf-pre)"
}

# PDF browser
function pdf() {
  cd ~/Documents/10_PDF檔/
  (marp_serve >/dev/null 2>&1 &)
  FILE=$(find . -path ./node_modules -prune -o -type f -name "*.pdf" -print | sed 's|^\./||' | fzf-pre)
  if [ -n "$FILE" ]; then
    if command -v open &>/dev/null; then
      open "$FILE"
    elif command -v xdg-open &>/dev/null; then
      xdg-open "$FILE"
    elif command -v gio &>/dev/null; then
      gio open "$FILE"
    else
      echo "No open command found (open/xdg-open/gio)" >&2
      return 127
    fi
  else
    echo "溫故而知新，可以為師矣"
  fi
}

# Slide editor with marp
function slide() {
  cd ~/Dropbox/slides/contents
  (check_and_start_marp_serve >/dev/null 2>&1 &)
  FILE=$(find . -path ./node_modules -prune -o -type f -name "*.md" -print | sed 's|^\./||' | fzf-pre)
  if [ -n "$FILE" ]; then
    if command -v open &>/dev/null; then
      (open "http://localhost:8080/$FILE" &)
    elif command -v xdg-open &>/dev/null; then
      (xdg-open "http://localhost:8080/$FILE" &)
    elif command -v gio &>/dev/null; then
      (gio open "http://localhost:8080/$FILE" &)
    else
      echo "No open command found (open/xdg-open/gio)" >&2
      return 127
    fi
    nvim +10 "$FILE"
  else
    echo "苟日新，日日新，又日新。"
  fi
}

# New project with deadline
newpj() {
  echo -n "Enter project name: "
  read project_name
  echo -n "Enter due month (1-12): "
  read month
  echo -n "Enter due day (1-31): "
  read day

  year=$(date +"%Y")
  project_name_sanitized=$(echo "$project_name" | tr ' ' '_')
  folder_path=~/Dropbox/sprint/"$year"-$(printf "%02d" $month)-$(printf "%02d" $day)-"$project_name_sanitized"

  mkdir -p "$folder_path"
  echo "# $project_name" >"$folder_path/README.md"
  cd "$folder_path"
  vim README.md
}

# Local todo.txt
function td() {
  [ -f ./todo.txt ] || touch ./todo.txt
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    grep -qxF "todo.txt" .gitignore || echo "todo.txt" >> .gitignore
  fi
  pter ./todo.txt
}
