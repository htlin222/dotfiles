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
    xdg-open "$1" &> /dev/null &
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
        0)
            ;;
            # output contains current directory
        101)
            JOSHUTO_CWD=$(cat "$OUTPUT_FILE")
            cd "$JOSHUTO_CWD"
            ;;
            # output selected files
        102)
            ;;
        *)
            echo "Exit code: $exit_code"
            ;;
    esac
}

function gist(){
    MY_FILE=$1
    # DESCRIPTION=$(cat "$MY_FILE" | grep 'description:' | cut -d':' -f2)
    # DESCRIPTION=$(cat "$MY_FILE" | grep 'description:' | cut -d':' -f2 | tr -d '"')
    DESCRIPTION=$(cat "$MY_FILE" | grep -iE 'description:|desc:' | cut -d':' -f2 | tr -d '"')
    gh gist create "$MY_FILE" --desc "$DESCRIPTION"
}
function check_and_start_marp_serve() {
    # Check if any marp serve process is already running
    if pgrep -f "marp .+ -s" > /dev/null; then
        echo "Marp serve is already running in the background."
    else
        echo "Starting Marp serve..."
        # Start Marp serve in the background
        marp ~/Dropbox/slides -s \
            --engine ~/Dropbox/slides/engine.js \
            --html --bespoke.progress \
            "$@" &
    fi
}

function marp_serve() {
    # kill -9 $(pgrep -f marp)
    if kill -9 $(pgrep -f marp) 2>/dev/null; then
        echo "進程已經成功終止"
    fi

    marp ~/Dropbox/slides -s \
        --engine ~/Dropbox/slides/engine.js \
        --html --bespoke.progress \
        "$@"
}
function killmarp() { kill -9 $(pgrep -f marp) }
function openai() { export OPENAI_API_KEY=$(op read "op://Dev/chat_GPT/api key") }
function rgnv() {
    rg_prefix='rg --column --line-number --no-heading --color=always --smart-case --glob "*.md" --max-depth 1'
    local result=$(fzf --bind "start:reload:$rg_prefix ''" \
            --bind "change:reload:$rg_prefix {q} || true" \
            --bind "enter:execute(echo {} )+abort" \
            --ansi --disabled \
            --height 80% --layout=reverse \
        --exit-0)
    if [ -n "$result" ]; then
        local filename=$(echo $result | cut -d':' -f1)
        local number=$(echo $result | sed 's/^[^:]*://; s/:.*//')
        nvim +$number "$filename"
    fi
}
function joinmp3(){
    cd $1
    for f in ./*.mp3; do echo "file '$f'" >> mylist.txt; done
    ffmpeg -y -f concat -safe 0 -i mylist.txt -c copy output.mp3
    cd -
}
function kavita(){
    GREEN="\033[32m"
    RESET="\033[0m"
    cd $HOME/Kavita
    echo "${GREEN}Serve at http://localhost:5555${RESET}"
    ./Kavita
    echo "${GREEN}ByeBye${RESET}"
    cd -
}
function make_exec_and_slide() {
    cd $HOME/Dropbox/slides/
    file=$(find . -type f -name "*.md" | sed 's|^\./||' | fzf-pre)
    chmod +x "$file"
    slides "$file"
}
function timezsh() {
    shell=${1-$SHELL}
    for i in $(seq 1 4); do /usr/bin/time $shell -i -c exit; done
}
function tre()
{ command tre "$@" -e && source "/tmp/tre_aliases_$USER" 2>/dev/null; }
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
function lfcd () {
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
    git commit  -m "Routine: Upload"
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
function note(){
    # Get the clipboard content and add a title
    cd ~/Dropbox/Medical/
    content=$(pbpaste)
    title="\n## Note: $(date +"%Y-%m-%d %H:%M")\n"
    content_with_title="$title$content"
    filename=$(fzf-pre)
    echo -e "$content_with_title" >> "$filename"
    vim $filename
}
function neovim_fzf(){
    FILE=$(fzf-pre)

    if [ -n "$FILE" ]; then
        # If a file was selected, open it with nvim at line 10
        nvim +10 "$FILE"
    else
        # If no file was selected, do nothing
    fi
}

function hh(){
    cd ~/Dropbox/
    (rsync -a --delete ~/Dropbox/Medical/ ~/.backup/medical/ &)
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
function study(){
    cd ~/Dropbox/Medical/
    (rsync -a --delete ~/Dropbox/Medical/ ~/.backup/medical/ &)
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
function recent_note(){
    cd ~/Dropbox/Medical/ &
    (python3 ~/Dropbox/scripts/gen_recent_list.py &)
    nvim +10 ~/Dropbox/Medical/recent.md
}
function studyrg(){
    cd ~/Dropbox/Medical/
    (rsync -a --delete ~/Dropbox/Medical/ ~/.backup/medical/ &)
    (python3 ~/Dropbox/scripts/gen_recent_list.py &)
    rgnv
}
function vimfzf(){
    nvim "$(fzf-pre)"
}

function patients(){
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
function pdf(){
    cd ~/Documents/10_PDF檔/
    (marp_serve > /dev/null 2>&1 &)
    FILE=$(find . \
            -path ./node_modules \
            -prune -o -type f -name "*.pdf" -print | \
            sed 's|^\./||' | \
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
function slide(){
    cd ~/Dropbox/slides
    (check_and_start_marp_serve > /dev/null 2>&1 &)
    FILE=$(find . \
            -path ./node_modules \
            -prune -o -type f -name "*.md" -print | \
            sed 's|^\./||' | \
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
function vimconfig(){
    cd ~/.config/nvim/lua/
    nvim ~/.config/nvim/lua/options.lua
}
function mkcd() {
    mkdir -p "$@" && cd "$_";
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
    rm "/opt/homebrew/Caskroom/$@";
}
function unblock() {
    sudo xattr -r -d com.apple.quarantine "$@";
}
function loading_animation() {
    chars=("⠇" "⠋" "⠙" "⠸" "⠴" "⠤" "⠦")
    while :; do
        for char in "${chars[@]}"; do
            printf "\rNow Start to Create a pyenv %s" "$char"
            sleep 0.1
        done
    done
}
function pyinit(){
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init - | sed s/precmd/chpwd/g)"
}
function mkpy() {
    GREEN="\033[32m"
    RESET="\033[0m"
    # loading_animation &
    # local anim_pid=$!

    echo "Creating new virtualenv: ${GREEN}$1${RESET}"
    # eval "$(pyenv init --path)"
    # eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
    # pyenv virtualenv 3.10.5 "$1"
    pyenv virtualenv 3.11.6 "$1"
    mkdir ./$1
    cd ./$1
    pyenv local $1
    pyenv activate $1
    # kill $anim_pid
    touch .gitignore
    pip freeze > requirements.txt
    echo ".python-version" >> .gitignore
    echo ".DS_Store" >> .gitignore
    echo "\rVirtualenv ${GREEN}$1${RESET} is created"
}
function jupyter-init(){
    pip install --upgrade pip
    pip install pandas jupyter notebook
    python3 -m ipykernel install --user --name $(pyenv version-name) --display-name "Python: $(pyenv version-name)"
    jupyter-lab
}
function playground() {
    local GREEN='\033[0;32m'
    local NC='\033[0m'

    # 取得當前日期和時間
    current_datetime=$(date +'%Y%m%d-%H%M')

    if [ $# -eq 0 ]; then
        folder_name=~/Desktop/playground.nosync/${current_datetime}
    else
        folder_name=~/Desktop/playground.nosync/$1
    fi
    # 創建目錄及其子目錄
    mkdir -p "$folder_name"
    mkdir -p "$folder_name/src"
    mkdir -p "$folder_name/doc"
    # 創建一個空的.env檔案
    touch $folder_name/.env
    # 創建.gitignore檔案，忽略.env檔案
    echo "**/.env" > $folder_name/.gitignore
    echo "# $folder_name\n\n> $current_datetime" > $folder_name/README.md
    # 進入新創建的目錄
    cd "$folder_name" || exit 1
    # uv venv
    # source .venv/bin/activate

    tmux new-window
    cd -
}
fucntion creat_today(){
    local filename="$HOME/Dropbox/inbox/$(date +"%Y-%m-%d").md"
    if [ -e "$filename" ]; then
        # File already exists, open it with vim
    else
        # File doesn't exist, create it with front matter
        echo "---" >> "$filename"
        echo "title: \"$(date +"%Y-%m-%d")\"" >> "$filename"
        echo "date: \"$(date +"%Y-%m-%d")\"" >> "$filename"
        echo "enableToc: false" >> "$filename"
        echo "tags:" >> "$filename"
        echo "  - diary" >> "$filename"
        echo "---" >> "$filename"
        echo "" >> "$filename"
        echo "> back to [[index]]" >> "$filename"
        echo "> go to [[todo_list]]" >> "$filename"
        echo "" >> "$filename"
        echo "<$(date +"%Y-%m-%d")>" >> "$filename"
        echo "" >> "$filename"
        echo "" >> "$filename"
        echo "---" >> "$filename"
    fi
    echo "$filename"
}

function dia() {
    (python3 ~/pyscripts/inbox.py &)
    local filename=$(creat_today)
    nvim +13 "$filename"
}

function fleet_of_thought() {
    local filename=$(creat_today)
    echo "💡 我有一個想法:"
    # cat >> "$filename"  # 將用戶輸入的內容附加到文件末尾
    read -r content  # 接收用戶輸入的內容
    # 將用戶輸入的內容附加到文件末尾
    local current_time=$(date +'%Y-%m-%d_%H%M')
    echo "- $content \`$current_time\`" >> "$filename"
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
        echo "---" >> "$filename"
        echo "title: \"$(date +"%Y-%m-%d")\"" >> "$filename"
        echo "date: \"$(date -u +"%Y-%m-%d")\"" >> "$filename"
        echo "author: \"林協霆\"" >> "$filename"
        echo "template: post" >> "$filename"
        echo "draft: true" >> "$filename"
        echo "description: \"這個人很懶不寫介紹\"" >> "$filename"
        echo "category: tutorial" >> "$filename"
        echo "---" >> "$filename"
        echo "" >> "$filename"
        echo "" >> "$filename"
        echo "## Fleet" >> "$filename"
        nvim +10 "$filename"
    fi
}

function updateblog() {
    blog="$HOME/Dropbox/blog/"
    git -C ~/blog/ pull
    rsync -az --delete --include="*.md" --exclude="*" "$blog" ~/blog/content/posts/
    if git -C ~/blog/ rev-parse --git-dir >/dev/null 2>&1; then
        git -C ~/blog/ add .
        git -C ~/blog/ commit -m "routine blogging ✏️ "
        git -C ~/blog/ push
        echo "👉 see action at https://app.netlify.com/sites/htlin/deploys"
        echo "👉 see website at https://htlin.site"
    else
        echo "🔔 Not a git repo"
    fi
}

function reloadiCloud(){
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

fucntion playlist() {
    playlist_name=$(yt-dlp "$1" -I 1:1 --skip-download --no-warning --print playlist_title | tr ' ' '_' | tr -d '/\\' | tr -d '[:punct:]')
    echo "start to generate playlist: ${playlist_name}"
    yt-dlp -i --get-filename -o "%(title)s" "$1" > "${playlist_name}.txt"
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
        --form model=whisper-1 | jq -r '.text' > "${output_file}"
    cat $output_file | pbcopy
    bat $output_file

}
newsprint() {
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
    echo "# $project_name" > "$folder_path/README.md"

    cd "$folder_path"
    vim README.md
}

