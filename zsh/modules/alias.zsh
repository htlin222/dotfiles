if uname | grep -q "Darwin"; then
  alias open="open"
  alias xdg-open="open"
else
  alias open="xdg-open"
  alias xdg-open="xdg-open"
fi
# alias R="/opt/homebrew/opt/r/bin/R --vanilla"
alias dtc='tmux detach-client'
alias n='pnpm'
alias tm='task-master'
alias nighty="printf '■□□□□□□□□□%.0s' {1..9}"
alias yolo='echo ""; claude --dangerously-skip-permissions'
alias taskmaster='task-master'
alias print7f='lp -d _172_21_75_1'
alias ymd='date +%F'
alias ndist='netlify deploy --prod --dir=dist'
alias win='windsurf'
alias forgit='git-forgit'
alias flash='make_flashcard'
# alias yarn='pnpm'
alias cd..='cd ..'
alias pipx='uv tool'
alias mcpconfig='nvim ~/Library/Application\ Support/Claude/claude_desktop_config.json'
alias man='colored man'
alias how="/Users/htlin/.dotfiles/shellscripts/how.sh"
alias ztop='zenith'
alias f="fix"
alias ec="echo"
alias nt='newsboat'
alias claupub="npm run build && netlify deploy --prod --dir=dist"
alias claupub_lab="cd ~/claude_lab && npm run build && netlify deploy --prod --dir=dist"
alias ripnetlify="rip ./.netlify"
alias artifact="cd ~/claude_lab/src/ && vim ~/claude_lab/src/App.jsx"
alias todo='pter ~/Dropbox/todo/todo.txt'
alias cdropbox='cd /Users/htlin/Library/CloudStorage/Dropbox/'
alias ignoredp='ignore_dropbox_folder'
alias ignore="xattr -w 'com.apple.fileprovider.ignore#P' 1"
alias zshconfig="vim ~/.zshrc"
alias clens="csvlens"
alias mkdir="mkdir -p"
alias pom="sh pom.sh"
alias ff="fleet_of_thought"
alias t="todo.sh"
alias one="tmux split-window -v -l 1"
alias wh="command -v"
alias dr="drafts"
alias pyinbin="pyinstaller --onedir --distpath ~/bin"
alias tt="taskwarrior-tui"
alias dpdf="sh $DOTFILES/shellscripts/rename_by_chatGPT.sh"
alias mac_gdrive="cd /Users/mac/Library/CloudStorage/GoogleDrive-ppoiu87@gmail.com/我的雲端硬碟"
alias up="ffsend upload"
alias uvinit="uv venv && source .venv/bin/activate"
# alias upip="uv pip install"
alias rsync_progress='rsync --archive --acls --xattrs --hard-links --verbose --progress'
alias "brewcask"="brew install --cask --no-quarantine"
alias bc='bc --quiet <(echo "scale=5;print\"scale=5\n\"")'
alias googledrive="cd /Users/htlin/Library/CloudStorage/GoogleDrive-ppoiu87@gmail.com/我的雲端硬碟"
alias xo='xdg-open'
alias lc='lolcat'
alias tldr='tldr'
alias asco="yazi ~/Documents/textbook/ASCO-SEP/"
alias ash="yazi ~/Documents/textbook/8th\ ASH-SEP/"
alias trash_restore='gio trash --restore "$(gio trash --list | fzf | cut -f 1)"'
alias ses='sesh connect $(sesh list | fzf)'
alias mv="mv -iv"
alias rm="rm -i"
alias rip="rip -i"
alias cp="cp -ivr"
alias which="type"
# alias hx="mcfly search"
alias br="broot"
alias lns="ln -s"
alias demo="cd ~/Dropbox/scripts/demo"
alias ranger='joshuto --output-file /tmp/joshutodir; LASTDIR=`cat /tmp/joshutodir`; cd "$LASTDIR"'
alias vc='vimconfig'
alias bm='vim $DOTFILES/bookmark.zsh'
alias brewdump='brew bundle dump --describe --force'
alias c='clear'
# alias cdf='cd $(find . -type d -print | fzf)'
alias cover='nvim +10 ~/Dropbox/slides/cover.md'
alias dj="curl -s -H 'Accept: application/json' https://icanhazdadjoke.com/ | jq -r '.joke'"
alias disk='diskonaut'
alias e='exit'
alias index='vim ~/Dropbox/Medical/index.md'
alias ffmpeg='ffmpeg-bar'
alias garden='publi.sh'
alias lf="lfcd"
alias fdfzf="fd --type f | fzf --preview 'bat --style=numbers --color=always {}'"
alias marp-serve="marp_serve"
alias marpimg="marp --theme-set ~/Dropbox/slides/themes --html --images png"
alias nstart="nvim --startuptime startup.log -c exit && tail -100 startup.log"
alias o='open'
alias ohmyzsh="vim ~/.oh-my-zsh"
alias opn='xdg-open'
alias lsgist='gh gist list --limit 30'
alias jj='cd ~/Dropbox/sprint/ && fcd && ls'
alias kk='cd ~/Dropbox/slowburn/ && fcd && ls'
alias pip="pip3"
alias pptxpdf="sh pptx_to_pdf.sh"
alias pt="patients"
alias e2u="python $HOME/pyscripts/emoji2utf8.py $1"
alias python="python3"
alias rain="curl wttr.in/Taipei"
alias re='reload'
alias rec="asciinema rec"
alias reload="exec '$SHELL'"
alias rl='ls ~/.Trash/files'
alias rn="recent_note"
alias seetrash='ls ~/.Trash/files'
alias sli="make_exec_and_slide"
alias snippets="vim ~/.dotfiles/neovim/vscode_snippets/garden.json"
alias st="study"
alias str="studyrg"
alias temp="curl wttr.in/Taipei?format='%l:+%c+%t+but+it+feels+like+%f+%h\\n'"
alias today='dia'
alias tree='lsd --tree'
alias uptodate="ddgr -n 5 'https://www.uptodate.com/'"
alias ur=undelfile
alias v='nvim'
alias vim='nvim'
alias vf='neovim_fzf'
alias viml='nvim --listen /tmp/nvim'
alias vimdiff='nvim -d'
alias vs='nvim -S'
alias vsauto='nvim -S .vim_auto_session.vim'
alias wpy="pyenv which python"
alias yt-mp4='yt-dlp --merge-output-format mp4'
alias zshconfig="vim ~/.zshrc"
# 查看最近一次失敗 run 的失敗步驟 log
alias gha-last-fail='gh run view --log-failed'
# 追蹤最近一次 run 的執行狀況（像看 live log）
alias gha-watch='gh run watch --compact --exit-status'
# 查看最近幾個失敗 run 的列表
alias gha-failed-list='gh run list --status failure'
