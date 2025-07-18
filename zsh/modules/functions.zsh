function cloneclaude() {
  # 移動到 $HOME
  cd $HOME || {
    echo "無法切換到 $HOME"
    return 1
  }
  # Clone 專案
  echo "正在克隆 htlin222/claude-artifact-runner..."
  if ! gh repo clone htlin222/claude-artifact-runner; then
    echo "克隆失敗，請檢查 gh CLI 是否正確安裝並登入。"
    return 1
  fi

  # 提示輸入新的資料夾名稱
  while true; do
    echo -n "請輸入新的資料夾名稱: "
    read -r new_folder_name

    if [[ -z "$new_folder_name" ]]; then
      echo "資料夾名稱不可為空，請重新輸入。"
    elif [[ -d "$new_folder_name" ]]; then
      echo "資料夾名稱已存在，請重新輸入。"
    else
      break
    fi
  done

  # 重命名資料夾
  mv claude-artifact-runner "$new_folder_name" || {
    echo "移動資料夾失敗"
    return 1
  }

  # 進入新資料夾
  cd "$new_folder_name" || {
    echo "無法進入資料夾 $new_folder_name"
    return 1
  }

  # 安裝 npm 依賴
  echo "正在執行 npm install..."
  if ! npm install; then
    echo "npm install 失敗，請檢查環境設定。"
    return 1
  fi

  # 移除 .git 資料夾
  echo "正在移除 .git 資料夾..."
  if ! rm -rf .git; then
    echo "移除 .git 資料夾失敗"
    return 1
  fi

  # 初始化新的 Git 儲存庫
  echo "正在初始化新的 Git 儲存庫..."
  if ! git init; then
    echo "git init 失敗"
    return 1
  fi

  # 添加檔案並提交
  echo "正在執行 git 操作..."
  if ! git add .; then
    echo "git add 失敗"
    return 1
  fi

  if ! git commit -m 'init'; then
    echo "git commit 失敗"
    return 1
  fi

  echo "專案已成功設定完成！"
}

function gitop() {
  if git rev-parse --show-toplevel >/dev/null 2>&1; then
    cd "$(git rev-parse --show-toplevel)"
  else
    echo "\033[31mNot in a git repository\033[0m" # 紅色提示
  fi
}
remind() {
  if ! command -v reminders >/dev/null 2>&1; then
    echo "reminders 未安裝" >&2
    return 1
  fi
  local list=${3:-Inbox}
  reminders add "$list" "$1" --due-date "$2"
}
function rename_in_sqb() {
  for file in *[*]*.txt; do
    newname=$(echo "$file" | sed -E 's/\[[^]]*\]//g')
    mv "$file" "$newname"
  done
}
fcd() {
  local dir
  dir=$(fd --type d | fzf) && cd "$dir"
}
netlify_pub() {
  netlify deploy -p --dir=$1
}
joinmp4() {
  for file in *.mp4; do
    echo "$file: $(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$file") seconds"
  done
  for file in *.mp4; do
    echo "file '$file'" >>filelist.txt
  done
  ffmpeg -f concat -safe 0 -i filelist.txt -c copy combined_$1.mp4
}
function unlock() {
  # find "/Applications" -type d -maxdepth 1 -name "*.app" -mmin -10 | while read app; do
  #     echo "👌Removing quarantine from: $app"
  #     sudo xattr -r -d com.apple.quarantine "$app"
  # done
  sh /Users/htlin/.dotfiles/shellscripts/do_not_block_app.sh
}
function ya() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
function fzf-pre() {
  fzf -m --height 50% \
    --layout=reverse \
    --inline-info \
    --preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200' \
    --preview-window 'right,50%,+{2}+3/3,~3,noborder' \
    --bind '?:toggle-preview'
}
function xdgopen() {
  # xdg-open "$1" &> /dev/null
  xdg-open "$1" &>/dev/null &
}
function nccn() {
  cd ~/Documents/guidelines/NCCN
  sh ~/Documents/guidelines/NCCN/nccn.sh
}
function joshuto_official() {
  ID="$$"
  mkdir -p /tmp/$USER
  OUTPUT_FILE="/tmp/$USER/joshuto-cwd-$ID"
  env joshuto --output-file "$OUTPUT_FILE" $@
  exit_code=$?

  case "$exit_code" in
  # regular exit
  0) ;;
    # output contains current directory
  101)
    JOSHUTO_CWD=$(cat "$OUTPUT_FILE")
    cd "$JOSHUTO_CWD"
    ;;
    # output selected files
  102) ;;
  *)
    echo "Exit code: $exit_code"
    ;;
  esac
}

function gist() {
  MY_FILE=$1
  # DESCRIPTION=$(cat "$MY_FILE" | grep 'description:' | cut -d':' -f2)
  # DESCRIPTION=$(cat "$MY_FILE" | grep 'description:' | cut -d':' -f2 | tr -d '"')
  DESCRIPTION=$(cat "$MY_FILE" | grep -iE 'description:|desc:' | cut -d':' -f2 | tr -d '"')
  gh gist create "$MY_FILE" --desc "$DESCRIPTION"
}
function check_and_start_marp_serve() {
  # Check if any marp serve process is already running
  if pgrep -f "marp .+ -s" >/dev/null; then
    echo "Marp serve is already running in the background."
  else
    echo "Starting Marp serve..."
    # Start Marp serve in the background
    SLIDES="$HOME/Dropbox/slides"
    marp "$SLIDES/contents/" -s \
      -c "$SLIDES/package.json" \
      "$@" &
  fi
}

function killmarp() {
  pkill -f marp
}
function openai() {
  export OPENAI_API_KEY=$(op read "op://Dev/chat_GPT/api key")
}
function rgtodo() {
  rg_prefix='rg -i --column --line-number --no-heading --sort=modified --color=always --smart-case --glob "*.md" "TODO:"'
  local result=$(fzf --bind "start:reload($rg_prefix '' | uniq)" \
    --bind "change:reload($rg_prefix {q} | uniq || true)" \
    --bind "enter:execute(echo {} | tee /tmp/fzf_result)+abort" \
    --ansi --disabled \
    --height 80% --layout=reverse \
    --exit-0)

  if [ -s /tmp/fzf_result ]; then
    local result=$(cat /tmp/fzf_result)
    local filename=$(echo $result | cut -d':' -f1)
    local number=$(echo $result | sed 's/^[^:]*://; s/:.*//')
    rm -f /tmp/fzf_result
    nvim +$number "$filename"
  fi
}
function rgnv() {
  rg_prefix='rg -i --column --line-number --no-heading --sort=modified --color=always --smart-case --glob "*.md" --max-depth 1'
  local result=$(fzf --bind "start:reload($rg_prefix '' | uniq)" \
    --bind "change:reload($rg_prefix {q} | uniq || true)" \
    --bind "enter:execute(echo {} | tee /tmp/fzf_result)+abort" \
    --ansi --disabled \
    --height 80% --layout=reverse \
    --exit-0)

  if [ -s /tmp/fzf_result ]; then
    local result=$(cat /tmp/fzf_result)
    local filename=$(echo $result | cut -d':' -f1)
    local number=$(echo $result | sed 's/^[^:]*://; s/:.*//')
    rm -f /tmp/fzf_result
    nvim +$number "$filename"
  fi
}
function joinmp3() {
  cd $1
  for f in ./*.mp3; do echo "file '$f'" >>mylist.txt; done
  ffmpeg -y -f concat -safe 0 -i mylist.txt -c copy output.mp3
  cd -
}
function make_exec_and_slide() {
  cd $HOME/Dropbox/slides/contents
  file=$(find . -type f -name "*.md" | sed 's|^\./||' | fzf-pre)
  chmod +x "$file"
  slides "$file"
}
function timezsh() {
  shell=${1-$SHELL}
  for i in $(seq 1 4); do /usr/bin/time $shell -i -c exit; done
}
function tre() { command tre "$@" -e && source "/tmp/tre_aliases_$USER" 2>/dev/null; }
function rga-fzf() {
  RG_PREFIX="rga --files-with-matches"
  local file
  file="$(
    FZF_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
      fzf --sort --preview="[[ ! -z {} ]] && rga --pretty --context 5 {q} {}" \
      --phony -q "$1" \
      --bind "change:reload:$RG_PREFIX {q}" \
      --preview-window="70%:wrap"
  )" &&
    echo "opening $file" &&
    xdg-open "$file"
}

function is_git_repo() {
  git rev-parse --is-inside-work-tree &>/dev/null
}
function lfcd() {
  tmp="$(mktemp)"
  # `command` is needed in case `lfcd` is aliased to `lf`
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
function zgit() {
  git add -A
  aicommits --type conventional # or -t conventional
  # aicommits config set OPENAI_KEY=$(op read op://Dev/chat_GPT/api\ key)
  git push
}
function ygit() {
  git add -A
  git commit -m "Routine: Upload"
  git push
}
function topdf() {
  /Applications/LibreOffice.app/Contents/MacOS/soffice --headless --convert-to pdf "$1"
  echo "🎉 $1 have been converted to pdf"
  # command mv $1 ./converted/$1
}
function chatgpt() {
  sh /Users/htlin/.dotfiles/shellscripts/chatGPT_CURL.sh -i "$1"
}
function undelfile() {
  mv -i ~/.Trash/files/$@ ./
}
function textexpand() {
  cd ~/.config/espanso/match
}
function dp() {
  cd $DOTFILES
  git -C $DOTFILES add .
  # git -C $DOTFILES commit -a -m "routine uploading ⬆️ "
  # do the ai commit
  aicommits
  git -C $DOTFILES push
  cd -
}

gitacp() {
  git add .
  aicommits
  git push
}

function dotpull() {
  git restore $DOTFILES
  git -C $DOTFILES pull
}
function sss() {
  $HOME/Dropbox/Medical/scripts/ls.sh
}
function simplenote() {
  nvim -c "SimplenoteList"
}
function note() {
  # Get the clipboard content and add a title
  cd ~/Dropbox/Medical/
  content=$(pbpaste)
  title="\n## Note: $(date +"%Y-%m-%d %H:%M")\n"
  content_with_title="$title$content"
  filename=$(fzf-pre)
  echo -e "$content_with_title" >>"$filename"
  vim $filename
}
function neovim_fzf() {
  FILE=$(fzf-pre)

  if [ -n "$FILE" ]; then
    # If a file was selected, open it with nvim at line 10
    nvim +10 "$FILE"
  else
    # If no file was selected, do nothing
  fi
}

function hh() {
  cd ~/Dropbox/
  # (rsync -a --delete ~/Dropbox/Medical/ ~/.backup/medical/ &)
  (python3 ~/Dropbox/scripts/gen_recent_list.py &)
  FILE=$(find . -type f -name "*.md" | sed 's|^\./||' | fzf-pre)

  if [ -n "$FILE" ]; then
    # If a file was selected, open it with nvim at line 10
    nvim +10 "$FILE"
  else
    # If no file was selected, do nothing
    cd ~/Dropbox/Medical/
    echo "獨學而無友，則孤陋而寡聞"
  fi
}
function study() {
  cd ~/Dropbox/Medical/
  # (rsync -a --delete ~/Dropbox/Medical/ ~/.backup/medical/ &)
  (python3 ~/Dropbox/scripts/gen_recent_list.py &)
  FILE=$(find . -type f -name "*.md" | sed 's|^\./||' | fzf-pre)

  if [ -n "$FILE" ]; then
    # If a file was selected, open it with nvim at line 10
    nvim +10 "$FILE"
  else
    # If no file was selected, do nothing
    echo "獨學而無友，則孤陋而寡聞"
  fi
}
function recent_note() {
  cd ~/Dropbox/Medical/
  # nvim +10 $(ls -lt | head -n 20 | awk '{print $NF}' | fzf --preview 'glow {}')
  file=$(ls -lt | head -n 30 | awk '{print $NF}' | fzf --preview 'bat --style=numbers --color=always {}')
  [ -n "$file" ] && vim "$file"
}
function studyrg() {
  cd ~/Dropbox/Medical/
  # (rsync -a --delete ~/Dropbox/Medical/ ~/.backup/medical/ &)
  # (python3 ~/Dropbox/scripts/gen_recent_list.py &)
  rgnv
}
function vimfzf() {
  nvim "$(fzf-pre)"
}

function patients() {
  cd ~/Dropbox/patients/
  nvim "$(find . -type f -name "*.md" | sed 's|^\./||' | fzf-pre)"
}
function cdf() {
  DIR=$(find * -type d | fzf)
  if [ -n "$DIR" ]; then
    # If a file was selected, open it with nvim at line 10
    cd $DIR
  else
    # If no file was selected, do nothing
    echo "千裡之行，始於足下"
  fi
}
function pdf() {
  cd ~/Documents/10_PDF檔/
  (marp_serve >/dev/null 2>&1 &)
  FILE=$(find . \
    -path ./node_modules \
    -prune -o -type f -name "*.pdf" -print |
    sed 's|^\./||' |
    fzf-pre)

  # Check if a file was selected
  if [ -n "$FILE" ]; then
    # If a file was selected, open it with nvim at line 10
    open "$FILE"
  else
    # If no file was selected, do nothing
    echo "溫故而知新，可以為師矣"
  fi
}
function slide() {
  cd ~/Dropbox/slides/contents
  (check_and_start_marp_serve >/dev/null 2>&1 &)
  FILE=$(find . \
    -path ./node_modules \
    -prune -o -type f -name "*.md" -print |
    sed 's|^\./||' |
    fzf-pre)

  # Check if a file was selected
  if [ -n "$FILE" ]; then
    # If a file was selected, open it with nvim at line 10
    (open "http://localhost:8080/$FILE" &)
    # TODO: (open "/Users/mac/Dropbox/slides/countdown.html" &)
    # or countdown.html?url=localhost:8080/chatGPT.md
    nvim +10 "$FILE"
  else
    # If no file was selected, do nothing
    echo "苟日新，日日新，又日新。"
  fi
}
function vimconfig() {
  cd ~/.config/nvim/lua/
  nvim ~/.config/nvim/lua/options.lua
}
function mkcd() {
  mkdir -p "$@" && cd "$_"
}
function icdn() {
  GREEN="\033[32m"
  RESET="\033[0m"
  echo "The following files are in the cloud nine:"
  find . -name '.*icloud'
  find . -name '.*icloud' | perl -pe 's|(.*)/.(.*).icloud|$1/$2|s' | while read file; do brctl download "$file"; done
  echo "\n${GREEN}Start to download all the files, be patient! ⏱️ ${RESET}"
}
function brewforget() {
  rm "/opt/homebrew/Caskroom/$@"
}
function unblock() {
  sudo xattr -r -d com.apple.quarantine "$@"
}
function dia() {
  (python3 ~/pyscripts/inbox.py &)
  local filename="$HOME/Dropbox/inbox/$(date +"%Y-%m-%d").md"
  if [ -e "$filename" ]; then
    # File already exists, open it with vim
    nvim +13 "$filename"
  else
    # File doesn't exist, create it with front matter
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

function draft() {
  cd "$HOME/Dropbox/blog/"
  local filename="$HOME/Dropbox/blog/$(date +"%Y-%m-%d-%H-%M").md"
  if [ -e "$filename" ]; then
    # File already exists, open it with vim
    nvim +10 "$filename"
  else
    echo "---" >>"$filename"
    echo "title: \"$(date +"%Y-%m-%d")\"" >>"$filename"
    echo "date: \"$(date -u +"%Y-%m-%d")\"" >>"$filename"
    echo "author: \"林協霆\"" >>"$filename"
    echo "template: post" >>"$filename"
    echo "draft: true" >>"$filename"
    echo "description: \"這個人很懶不寫介紹\"" >>"$filename"
    echo "category: tutorial" >>"$filename"
    echo "---" >>"$filename"
    echo "" >>"$filename"
    echo "" >>"$filename"
    echo "## Fleet" >>"$filename"
    nvim +10 "$filename"
  fi
}

function reloadiCloud() {
  killall bird
  killall cloudd
  # cd ~/Library/Application\ Support
  # rm -rf CloudDocs
  # cd -
}
function snippets() {
  nvim $HOME/.dotfiles/neovim/snippets/init.lua
}
function yt-mp3() {
  yt-dlp --extract-audio --audio-format mp3 $1
}
function yt-mp3-list() {
  folder_name=$(basename "$(pwd)")
  # echo "$folder_name" >> album.txt
  # echo "unknown" >> artist.txt
  yt-dlp --extract-audio --audio-format mp3 $(pbpaste) -o "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s"
}
function yt-playlist() {
  yt-dlp "$1" -o "%(playlist)s/%(playlist_index)s_%(title)s.%(ext)s"
}

function yt-list-cookies() {
  # for bilibili 1080p
  yt-dlp "$1" -o "%(playlist)s/%(playlist_index)s_%(title)s.%(ext)s" --cookies-from-browser edge
}
function inbox() {
  cd ~/Dropbox/inbox/
  python3 ~/pyscripts/inbox.py
  nvim +10 ~/Dropbox/inbox/index.md
}
function mediumog() {
  if [ $# -eq 0 ]; then
    echo "Usage: mediumog <slide_name>"
    return 1
  fi

  local slide_name="$1"
  sh ~/.dotfiles/shellscripts/gen_medium_og.sh "$slide_name"
}
function playlist() {
  playlist_name=$(yt-dlp "$1" -I 1:1 --skip-download --no-warning --print playlist_title | tr ' ' '_' | tr -d '/\\' | tr -d '[:punct:]')
  echo "start to generate playlist: ${playlist_name}"
  yt-dlp -i --get-filename -o "%(title)s" "$1" >"${playlist_name}.txt"
}
# a script to install a specific version of a formula from homebrew-core
# USAGE: brew-switch <formula> <version>
function brew-switch {
  local _formula=$1
  local _version=$2

  # fail for missing arguments
  if [[ -z "$_formula" || -z "$_version" ]]; then
    echo "USAGE: brew-switch <formula> <version>"
    return 1
  fi

  # ensure 'gh' is installed
  if [[ -z "$(command -v gh)" ]]; then
    echo ">>> ERROR: 'gh' must be installed to run this script"
    return 1
  fi

  # find the newest commit for the given formula and version
  # NOTE: we get the URL, rather than the SHA, because sometimes the commit belongs to an older repo
  local _commit_url=$(
    gh search commits \
      --owner "Homebrew" \
      --repo "homebrew-core" \
      --limit 1 \
      --sort "committer-date" \
      --order "desc" \
      --json "url" \
      --jq ".[0].url" \
      "\"${_formula}\" \"${_version}\""
  )

  # fail if no commit was found
  if [[ -z "$_commit_url" ]]; then
    echo "ERROR: No commit found for ${_formula}@${_version}"
    return 1
  else
    echo "INFO: Found commit ${_commit_url} for ${_formula}@${_version}"
  fi

  # get the 'raw.githubusercontent.com' URL from the commit URL
  local _raw_url_base=$(
    echo "$_commit_url" |
      sed -E 's|github.com/([^/]+)/([^/]+)/commit/(.*)|raw.githubusercontent.com/\1/\2/\3|'
  )

  local _formula_path="/tmp/${_formula}.rb"

  # download the formula file from the commit
  echo ""
  local _repo_path="Formula/${_formula:0:1}/${_formula}.rb"
  local _raw_url="${_raw_url_base}/${_repo_path}"
  echo "INFO: Downloading ${_raw_url}"
  if ! curl -fL "$_raw_url" -o "$_formula_path"; then
    echo "WARNING: Download failed, trying OLD formula path"
    echo ""
    _repo_path="Formula/${_formula}.rb"
    _raw_url="${_raw_url_base}/${_repo_path}"
    echo "INFO: Downloading ${_raw_url}"
    if ! curl -fL "$_raw_url" -o "$_formula_path"; then
      echo "WARNING: Download failed, trying ANCIENT formula path"
      echo ""
      _repo_path="/Library/Formula/${_formula}.rb"
      _raw_url="${_raw_url_base}/${_repo_path}"
      echo "INFO: Downloading ${_raw_url}"
      if ! curl -fL "$_raw_url" -o "$_formula_path"; then
        echo "ERROR: Failed to download ${_formula} from ${_raw_url}"
        return 1
      fi
    fi
  fi

  # if the formula is already installed, uninstall it
  if brew ls --versions "$_formula" >/dev/null; then
    echo ""
    echo "WARNING: '$_formula' already installed, do you want to uninstall it? [y/N]"
    local _reply=$(bash -c "read -n 1 -r && echo \$REPLY")
    echo ""
    if [[ $_reply =~ ^[Yy]$ ]]; then
      echo "INFO: Uninstalling '$_formula'"
      brew unpin "$_formula"
      if ! brew uninstall "$_formula"; then
        echo "ERROR: Failed to uninstall '$_formula'"
        return 1
      fi
    else
      echo "ERROR: '$_formula' is already installed, aborting"
      return 1
    fi
  fi

  # install the downloaded formula
  echo "INFO: Installing ${_formula}@${_version} from local file: $_formula_path"
  brew install --formula "$_formula_path"
  brew pin "$_formula"
}
function convert_mp4_to_gif() {
  if [[ -z "$1" ]]; then
    echo "Usage: convert_mp4_to_gif <input_file.mp4>"
    return 1
  fi

  local input_file=$1

  # 检查文件扩展名是否为 .mp4
  if [[ "${input_file: -4}" != ".mp4" ]]; then
    echo "The input file must be a .mp4 file."
    return 1
  fi

  local output_file="${input_file%.mp4}.gif"

  ffmpeg -y -i "$input_file" -r 15 -vf "scale=720:-1" -ss 00:00:00 -to 00:00:10 "$output_file"
  echo "GIF created: $output_file"
}

transcribe_audio() {
  local file_path=$1
  local file_name=$(basename "$file_path")
  local output_file="${file_name}.txt"

  curl --request POST \
    --url https://api.openai.com/v1/audio/transcriptions \
    --header "Authorization: Bearer $OPENAI_API_KEY" \
    --header "Content-Type: multipart/form-data" \
    --form file=@${file_path} \
    --form model=whisper-1 | jq -r '.text' >"${output_file}"
  cat $output_file | pbcopy
  bat $output_file

}
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
function notify() {
  local title="$1"
  local content="$2"
  osascript -e "display notification \"$content\" with title \"$title\""
}
syncq() {
  # 定義顏色
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  NC='\033[0m' # 無顏色

  printf "${YELLOW}Are you sure you want to sync the files? (y/n)${NC} "
  read confirm
  if [ "$confirm" = "y" ]; then
    printf "${GREEN}Syncing files...${NC}\n"
    rsync -av --exclude '.*' /Users/htlin/quarto-revealjs-starter/_extensions /Users/htlin/quarto-revealjs-starter/assets /Users/htlin/quarto-revealjs-starter/_quarto.yml ./
    printf "${GREEN}Sync complete.${NC}\n"
  else
    printf "${RED}Sync canceled.${NC}\n"
  fi
}
# 在 .zshrc 中定義函數
function delete_line_with_fzf() {
  local file="$1"

  # 檢查文件是否存在
  if [[ ! -f "$file" ]]; then
    echo "文件 $file 不存在"
    return 1
  fi

  # 用 fzf 選擇一行
  local selected_line=$(cat "$file" | fzf)

  # 檢查是否選定了某行
  if [[ -n "$selected_line" ]]; then
    # 顯示上下文行和被刪除行
    echo "上下文行："
    grep -C 1 -F "$selected_line" "$file" | sed "s/$selected_line/\x1b[31m&\x1b[0m/"

    # 使用 mktemp 創建臨時文件
    local temp_file=$(mktemp)

    # 刪除選定的那一行並寫入臨時文件
    grep -vF "$selected_line" "$file" >"$temp_file"

    # 檢查 grep 命令是否成功
    if [[ $? -eq 0 ]]; then
      # 替換原文件
      mv "$temp_file" "$file"
      echo -e "\n已刪除的行：\x1b[31m$selected_line\x1b[0m"
    else
      echo "刪除過程中發生錯誤"
      rm "$temp_file"
      return 1
    fi
  else
    echo "未選定任何行"
  fi
}
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
chore() {
  for file in *; do
    # 檢查是否是檔案，並且非資料夾或符號連結
    if [[ -f "$file" && ! -L "$file" ]]; then
      # 獲取檔案最後修改時間
      mod_date=$(date -r "$file" +"%Y-%m-%d")

      # 檢查檔案名稱是否已經以 yyyy-mm-dd 開頭
      if [[ ! "$file" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}_ ]]; then
        # 去掉副檔名來建立資料夾名稱
        filename_no_ext="${file%.*}"
        new_folder="${mod_date}_${filename_no_ext}"

        # 建立新目錄
        mkdir -p "$new_folder"

        # 移動檔案
        mv "$file" "$new_folder/"

        # 顯示成功訊息
        echo "Moved $file to $new_folder/"
      else
        echo "$file already starts with a date, skipping."
      fi
    elif [[ -L "$file" ]]; then
      echo "$file is a symlink, skipping."
    fi
  done
}
start_fetch_mcp() {
  local TARGET_DIR="/Users/htlin/fetch-mcp"
  # 檢查目錄是否存在
  if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory $TARGET_DIR does not exist."
    return 1
  fi
  # 進入目錄
  cd "$TARGET_DIR" || return 1
  # 啟動 pnpm 並讓其在背景執行，不受終端影響
  nohup pnpm start >pnpm.log 2>&1 &
  disown
  echo "pnpm started in background. Logs: $TARGET_DIR/pnpm.log"
}

toslides() {
  local fontsize=${1:-72}
  local foldername="${PWD##*/}"
  local output="${foldername}_slides.pdf"
  local tmp_prefix="wm_"
  local exts=("jpg" "png" "JPG" "PNG")
  local has_images=false

  # 檢查是否有圖片
  for ext in "${exts[@]}"; do
    for img in *."$ext"; do
      [[ -e "$img" ]] || continue
      has_images=true
      break 2
    done
  done

  if ! $has_images; then
    echo "⚠️ No .jpg or .png files found in current directory."
    return 1
  fi

  echo "🔧 Adding filename watermark with font size $fontsize..."

  for ext in "${exts[@]}"; do
    for img in *."$ext"; do
      [[ -e "$img" ]] || continue
      local out="${tmp_prefix}${img}"
      magick "$img" -gravity southeast -pointsize $fontsize \
        -fill white -undercolor black \
        -annotate +20+20 "$img" "$out"
    done
  done

  echo "🧾 Combining into $output..."
  img2pdf ${tmp_prefix}* -o "$output" --auto-orient

  echo "🧹 Cleaning up..."
  rm -f ${tmp_prefix}*

  echo "✅ Done! Output: $output"
}
function td() {
  [ -f ./todo.txt ] || touch ./todo.txt
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    grep -qxF "todo.txt" .gitignore || echo "todo.txt" >> .gitignore
  fi
  pter ./todo.txt
}
function capimg() {
  command -v magick >/dev/null 2>&1 || { echo "magick 未安裝或不在 PATH 中"; return 1 }
  local file="${1:-info.txt}"
  magick -size 1720x880 -background white -fill black -font Courier -pointsize 48 caption:@"$file" -gravity center -extent 1920x1080 00_cover.png
}
ignore_dropbox_file() {
  local filepath
  filepath=$(find "$HOME/Library/CloudStorage/Dropbox" -type f | fzf)
  [ -n "$filepath" ] && xattr -w 'com.apple.fileprovider.ignore#P' 1 "$filepath"
}
ignore_dropbox_folder() {
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
    # 正確抓取檔案名，支援空白路徑
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

function chpwd() {
  echo "你現在在 $(pwd)"
  for dir in .venv node_modules; do
    if [[ -d $dir ]]; then
      xattr -w 'com.apple.fileprovider.ignore#P' 1 "$dir"
    fi
  done
}

function anki() {
    local anki_dir="${ANKI_DIR:-$HOME/anki}"
    local filename="$(date +%Y%m%d).md"
    local filepath="$anki_dir/$filename"
    local date_formatted="$(date +%Y%m%d)"

    # Create directory if it doesn't exist
    if [[ ! -d "$anki_dir" ]]; then
        mkdir -p "$anki_dir" || {
            echo "Error: Failed to create directory $anki_dir" >&2
            return 1
        }
    fi

    # Check if nvim is available
    if ! command -v nvim >/dev/null 2>&1; then
        echo "Error: nvim not found in PATH" >&2
        return 1
    fi

    # Create file with initial content if it doesn't exist
    if [[ ! -f "$filepath" ]]; then
        {
            echo "# 00_Inbox "
            echo ""
            echo "## Subdeck: $date_formatted"
            echo ""
            echo "### "
        } > "$filepath" || {
            echo "Error: Failed to create file $filepath" >&2
            return 1
        }
        echo "Created new anki file: $filepath"
    fi

    # Open with nvim, cursor at end
    nvim + "$filepath"
}

add_path_to_claude_filesystem() {
  local config_path="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
  local current_path="$(pwd)"
  local temp_file="$(mktemp)"

  if grep -Fq "$current_path" "$config_path"; then
    echo "✅ Path already exists in filesystem args."
    return 0
  fi

  if command -v jq >/dev/null 2>&1; then
    jq --arg newPath "$current_path" '
      .mcpServers.filesystem.args += [$newPath]
    ' "$config_path" > "$temp_file" && mv "$temp_file" "$config_path"
    echo "✅ Added $current_path to filesystem args."
  else
    echo "⚠️ jq not found. Please install jq or edit manually for safety."
    return 1
  fi
}
