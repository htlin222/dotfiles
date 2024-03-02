function rename_in_sqb() {
    for file in *[*]*.txt; do
        newname=$(echo "$file" | sed -E 's/\[[^]]*\]//g')
        mv "$file" "$newname"
    done
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
function wikiupdate() {
    rsync -az --delete ~/Dropbox/Medical/wiki/ ~/wiki/docs/
    echo "rsync complete at %r"
    git -C ~/wiki/ add .
    git -C ~/wiki/ commit -m "update contents at %r"
    git -C ~/wiki/ push
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
    cd ~/.config/nvim/lua/custom
    nvim init.lua
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

    tmux new-window
    cd -
}

function dia() {
    local filename="$HOME/Dropbox/inbox/$(date +"%Y-%m-%d").md"
    (python3 ~/pyscripts/inbox.py &)
    if [ -e "$filename" ]; then
        # File already exists, open it with vim
        nvim +13 "$filename"
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
        # Open the file in a text editor (e.g., Vim)
        # nvim +10 -c 'normal O' -c 'startinsert' "$filename"
        nvim +13 "$filename"
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
        echo "date: \"$(date -u +"%Y-%m-%dT%H:%M:%S.%NZ")\"" >> "$filename"
        echo "template: post" >> "$filename"
        echo "draft: true" >> "$filename"
        echo "description: \"這個人很懶不寫介紹\"" >> "$filename"
        echo "category: tutorial" >> "$filename"
        echo "---" >> "$filename"
        echo "" >> "$filename"
        echo "" >> "$filename"
        nvim +10 "$filename"
    fi
}

function updateblog() {
    blog="$HOME/Dropbox/blog/"
    rsync -az --delete --include="*.md" --exclude="*" "$blog" ~/blog/content/posts/
    if git -C ~/blog/ rev-parse --git-dir >/dev/null 2>&1; then
        git -C ~/blog/ pull
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

