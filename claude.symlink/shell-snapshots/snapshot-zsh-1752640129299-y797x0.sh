# Snapshot file
# Unset all aliases to avoid conflicts with functions
unalias -a 2>/dev/null || true
# Functions
→chroma/-alias.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/-autoload.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/-autorandr.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/-awk.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/-docker.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/-example.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/-fast-theme.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/-fpath_peq.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/-git.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/-grep.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/-hub.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/-ionice.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/-lab.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/-make.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/-nice.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/-nmcli.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/-node.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/-ogit.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/-perl.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/-precommand.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/-printf.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/-ruby.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/-scp.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/-sh.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/-source.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/-ssh.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/-subcommand.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/-subversion.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/-vim.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/-whatis.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/-which.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/-zinit.ch () {
	# undefined
	builtin autoload -XUz
}
→chroma/main-chroma.ch () {
	# undefined
	builtin autoload -XUz
}
.fast-make-targets () {
	# undefined
	builtin autoload -XUz
}
.fast-read-ini-file () {
	# undefined
	builtin autoload -XUz
}
.fast-run-command () {
	# undefined
	builtin autoload -XUz
}
.fast-run-git-command () {
	# undefined
	builtin autoload -XUz
}
.fast-zts-read-all () {
	# undefined
	builtin autoload -XUz
}
/fshdbg () {
	print -r -- "$@" >>| /tmp/reply
}
VCS_INFO_formats () {
	setopt localoptions noksharrays NO_shwordsplit
	local msg tmp
	local -i i
	local -A hook_com
	hook_com=(action "$1" action_orig "$1" branch "$2" branch_orig "$2" base "$3" base_orig "$3" staged "$4" staged_orig "$4" unstaged "$5" unstaged_orig "$5" revision "$6" revision_orig "$6" misc "$7" misc_orig "$7" vcs "${vcs}" vcs_orig "${vcs}") 
	hook_com[base-name]="${${hook_com[base]}:t}" 
	hook_com[base-name_orig]="${hook_com[base-name]}" 
	hook_com[subdir]="$(VCS_INFO_reposub ${hook_com[base]})" 
	hook_com[subdir_orig]="${hook_com[subdir]}" 
	: vcs_info-patch-9b9840f2-91e5-4471-af84-9e9a0dc68c1b
	for tmp in base base-name branch misc revision subdir
	do
		hook_com[$tmp]="${hook_com[$tmp]//\%/%%}" 
	done
	VCS_INFO_hook 'post-backend'
	if [[ -n ${hook_com[action]} ]]
	then
		zstyle -a ":vcs_info:${vcs}:${usercontext}:${rrn}" actionformats msgs
		(( ${#msgs} < 1 )) && msgs[1]=' (%s)-[%b|%a]%u%c-' 
	else
		zstyle -a ":vcs_info:${vcs}:${usercontext}:${rrn}" formats msgs
		(( ${#msgs} < 1 )) && msgs[1]=' (%s)-[%b]%u%c-' 
	fi
	if [[ -n ${hook_com[staged]} ]]
	then
		zstyle -s ":vcs_info:${vcs}:${usercontext}:${rrn}" stagedstr tmp
		[[ -z ${tmp} ]] && hook_com[staged]='S'  || hook_com[staged]=${tmp} 
	fi
	if [[ -n ${hook_com[unstaged]} ]]
	then
		zstyle -s ":vcs_info:${vcs}:${usercontext}:${rrn}" unstagedstr tmp
		[[ -z ${tmp} ]] && hook_com[unstaged]='U'  || hook_com[unstaged]=${tmp} 
	fi
	if [[ ${quiltmode} != 'standalone' ]] && VCS_INFO_hook "pre-addon-quilt"
	then
		local REPLY
		VCS_INFO_quilt addon
		hook_com[quilt]="${REPLY}" 
		unset REPLY
	elif [[ ${quiltmode} == 'standalone' ]]
	then
		hook_com[quilt]=${hook_com[misc]} 
	fi
	(( ${#msgs} > maxexports )) && msgs[$(( maxexports + 1 )),-1]=() 
	for i in {1..${#msgs}}
	do
		if VCS_INFO_hook "set-message" $(( $i - 1 )) "${msgs[$i]}"
		then
			zformat -f msg ${msgs[$i]} a:${hook_com[action]} b:${hook_com[branch]} c:${hook_com[staged]} i:${hook_com[revision]} m:${hook_com[misc]} r:${hook_com[base-name]} s:${hook_com[vcs]} u:${hook_com[unstaged]} Q:${hook_com[quilt]} R:${hook_com[base]} S:${hook_com[subdir]}
			msgs[$i]=${msg} 
		else
			msgs[$i]=${hook_com[message]} 
		fi
	done
	hook_com=() 
	backend_misc=() 
	return 0
}
add-zsh-hook () {
	emulate -L zsh
	local -a hooktypes
	hooktypes=(chpwd precmd preexec periodic zshaddhistory zshexit zsh_directory_name) 
	local usage="Usage: add-zsh-hook hook function\nValid hooks are:\n  $hooktypes" 
	local opt
	local -a autoopts
	integer del list help
	while getopts "dDhLUzk" opt
	do
		case $opt in
			(d) del=1  ;;
			(D) del=2  ;;
			(h) help=1  ;;
			(L) list=1  ;;
			([Uzk]) autoopts+=(-$opt)  ;;
			(*) return 1 ;;
		esac
	done
	shift $(( OPTIND - 1 ))
	if (( list ))
	then
		typeset -mp "(${1:-${(@j:|:)hooktypes}})_functions"
		return $?
	elif (( help || $# != 2 || ${hooktypes[(I)$1]} == 0 ))
	then
		print -u$(( 2 - help )) $usage
		return $(( 1 - help ))
	fi
	local hook="${1}_functions" 
	local fn="$2" 
	if (( del ))
	then
		if (( ${(P)+hook} ))
		then
			if (( del == 2 ))
			then
				set -A $hook ${(P)hook:#${~fn}}
			else
				set -A $hook ${(P)hook:#$fn}
			fi
			if (( ! ${(P)#hook} ))
			then
				unset $hook
			fi
		fi
	else
		if (( ${(P)+hook} ))
		then
			if (( ${${(P)hook}[(I)$fn]} == 0 ))
			then
				typeset -ga $hook
				set -A $hook ${(P)hook} $fn
			fi
		else
			typeset -ga $hook
			set -A $hook $fn
		fi
		autoload $autoopts -- $fn
	fi
}
alias_value () {
	(( $+aliases[$1] )) && echo $aliases[$1]
}
anki () {
	local anki_dir="${ANKI_DIR:-$HOME/anki}" 
	local filename="$(date +%Y%m%d).md" 
	local filepath="$anki_dir/$filename" 
	local date_formatted="$(date +%Y%m%d)" 
	if [[ ! -d "$anki_dir" ]]
	then
		mkdir -p -p "$anki_dir" || {
			echo "Error: Failed to create directory $anki_dir" >&2
			return 1
		}
	fi
	if ! command -v nvim > /dev/null 2>&1
	then
		echo "Error: nvim not found in PATH" >&2
		return 1
	fi
	if [[ ! -f "$filepath" ]]
	then
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
	nvim + "$filepath"
}
azure_prompt_info () {
	return 1
}
bashcompinit () {
	# undefined
	builtin autoload -XUz
}
br () {
	lazyload br -- $'_load_broot' && broot "$@"
}
brew-switch () {
	local _formula=$1 
	local _version=$2 
	if [[ -z "$_formula" || -z "$_version" ]]
	then
		echo "USAGE: brew-switch <formula> <version>"
		return 1
	fi
	if [[ -z "$(command -v gh)" ]]
	then
		echo ">>> ERROR: 'gh' must be installed to run this script"
		return 1
	fi
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
	if [[ -z "$_commit_url" ]]
	then
		echo "ERROR: No commit found for ${_formula}@${_version}"
		return 1
	else
		echo "INFO: Found commit ${_commit_url} for ${_formula}@${_version}"
	fi
	local _raw_url_base=$(
    echo "$_commit_url" |
      sed -E 's|github.com/([^/]+)/([^/]+)/commit/(.*)|raw.githubusercontent.com/\1/\2/\3|'
  ) 
	local _formula_path="/tmp/${_formula}.rb" 
	echo ""
	local _repo_path="Formula/${_formula:0:1}/${_formula}.rb" 
	local _raw_url="${_raw_url_base}/${_repo_path}" 
	echo "INFO: Downloading ${_raw_url}"
	if ! curl -fL "$_raw_url" -o "$_formula_path"
	then
		echo "WARNING: Download failed, trying OLD formula path"
		echo ""
		_repo_path="Formula/${_formula}.rb" 
		_raw_url="${_raw_url_base}/${_repo_path}" 
		echo "INFO: Downloading ${_raw_url}"
		if ! curl -fL "$_raw_url" -o "$_formula_path"
		then
			echo "WARNING: Download failed, trying ANCIENT formula path"
			echo ""
			_repo_path="/Library/Formula/${_formula}.rb" 
			_raw_url="${_raw_url_base}/${_repo_path}" 
			echo "INFO: Downloading ${_raw_url}"
			if ! curl -fL "$_raw_url" -o "$_formula_path"
			then
				echo "ERROR: Failed to download ${_formula} from ${_raw_url}"
				return 1
			fi
		fi
	fi
	if brew ls --versions "$_formula" > /dev/null
	then
		echo ""
		echo "WARNING: '$_formula' already installed, do you want to uninstall it? [y/N]"
		local _reply=$(bash -c "read -n 1 -r && echo \$REPLY") 
		echo ""
		if [[ $_reply =~ ^[Yy]$ ]]
		then
			echo "INFO: Uninstalling '$_formula'"
			brew unpin "$_formula"
			if ! brew uninstall "$_formula"
			then
				echo "ERROR: Failed to uninstall '$_formula'"
				return 1
			fi
		else
			echo "ERROR: '$_formula' is already installed, aborting"
			return 1
		fi
	fi
	echo "INFO: Installing ${_formula}@${_version} from local file: $_formula_path"
	brew install --formula "$_formula_path"
	brew pin "$_formula"
}
brewforget () {
	rm -i "/opt/homebrew/Caskroom/$@"
}
bzr_prompt_info () {
	BZR_CB=`bzr nick 2> /dev/null | grep -v "ERROR" | cut -d ":" -f2 | awk -F / '{print "bzr::"$1}'` 
	if [ -n "$BZR_CB" ]
	then
		BZR_DIRTY="" 
		[[ -n `bzr status` ]] && BZR_DIRTY=" %{$fg[red]%} * %{$fg[green]%}" 
		echo "$ZSH_THEME_SCM_PROMPT_PREFIX$BZR_CB$BZR_DIRTY$ZSH_THEME_GIT_PROMPT_SUFFIX"
	fi
}
capimg () {
	command -v magick > /dev/null 2>&1 || {
		echo "magick 未安裝或不在 PATH 中"
		return 1
	}
	local file="${1:-info.txt}" 
	magick -size 1720x880 -background white -fill black -font Courier -pointsize 48 caption:@"$file" -gravity center -extent 1920x1080 00_cover.png
}
cdf () {
	DIR=$(find * -type d | fzf) 
	if [ -n "$DIR" ]
	then
		cd $DIR
	else
		echo "千裡之行，始於足下"
	fi
}
chatgpt () {
	sh /Users/htlin/.dotfiles/shellscripts/chatGPT_CURL.sh -i "$1"
}
check_and_start_marp_serve () {
	if pgrep -f "marp .+ -s" > /dev/null
	then
		echo "Marp serve is already running in the background."
	else
		echo "Starting Marp serve..."
		SLIDES="$HOME/Dropbox/slides" 
		marp "$SLIDES/contents/" -s -c "$SLIDES/package.json" "$@" &
	fi
}
chore () {
	for file in *
	do
		if [[ -f "$file" && ! -L "$file" ]]
		then
			mod_date=$(date -r "$file" +"%Y-%m-%d") 
			if [[ ! "$file" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}_ ]]
			then
				filename_no_ext="${file%.*}" 
				new_folder="${mod_date}_${filename_no_ext}" 
				mkdir -p -p "$new_folder"
				mv -iv "$file" "$new_folder/"
				echo "Moved $file to $new_folder/"
			else
				echo "$file already starts with a date, skipping."
			fi
		elif [[ -L "$file" ]]
		then
			echo "$file is a symlink, skipping."
		fi
	done
}
chpwd () {
	echo "你現在在 $(pwd)"
	for dir in .venv node_modules
	do
		if [[ -d $dir ]]
		then
			xattr -w 'com.apple.fileprovider.ignore#P' 1 "$dir"
		fi
	done
}
chruby_prompt_info () {
	return 1
}
clipcopy () {
	cat "${1:-/dev/stdin}" | pbcopy
}
clippaste () {
	pbpaste
}
cloneclaude () {
	cd $HOME || {
		echo "無法切換到 $HOME"
		return 1
	}
	echo "正在克隆 htlin222/claude-artifact-runner..."
	if ! op plugin run -- gh repo clone htlin222/claude-artifact-runner
	then
		echo "克隆失敗，請檢查 gh CLI 是否正確安裝並登入。"
		return 1
	fi
	while true
	do
		echo -n "請輸入新的資料夾名稱: "
		read -r new_folder_name
		if [[ -z "$new_folder_name" ]]
		then
			echo "資料夾名稱不可為空，請重新輸入。"
		elif [[ -d "$new_folder_name" ]]
		then
			echo "資料夾名稱已存在，請重新輸入。"
		else
			break
		fi
	done
	mv -iv claude-artifact-runner "$new_folder_name" || {
		echo "移動資料夾失敗"
		return 1
	}
	cd "$new_folder_name" || {
		echo "無法進入資料夾 $new_folder_name"
		return 1
	}
	echo "正在執行 npm install..."
	if ! npm install
	then
		echo "npm install 失敗，請檢查環境設定。"
		return 1
	fi
	echo "正在移除 .git 資料夾..."
	if ! rm -i -rf .git
	then
		echo "移除 .git 資料夾失敗"
		return 1
	fi
	echo "正在初始化新的 Git 儲存庫..."
	if ! git init
	then
		echo "git init 失敗"
		return 1
	fi
	echo "正在執行 git 操作..."
	if ! git add .
	then
		echo "git add 失敗"
		return 1
	fi
	if ! git commit -m 'init'
	then
		echo "git commit 失敗"
		return 1
	fi
	echo "專案已成功設定完成！"
}
colors () {
	emulate -L zsh
	typeset -Ag color colour
	color=(00 none 01 bold 02 faint 22 normal 03 italic 23 no-italic 04 underline 24 no-underline 05 blink 25 no-blink 07 reverse 27 no-reverse 08 conceal 28 no-conceal 30 black 40 bg-black 31 red 41 bg-red 32 green 42 bg-green 33 yellow 43 bg-yellow 34 blue 44 bg-blue 35 magenta 45 bg-magenta 36 cyan 46 bg-cyan 37 white 47 bg-white 39 default 49 bg-default) 
	local k
	for k in ${(k)color}
	do
		color[${color[$k]}]=$k 
	done
	for k in ${color[(I)3?]}
	do
		color[fg-${color[$k]}]=$k 
	done
	for k in grey gray
	do
		color[$k]=${color[black]} 
		color[fg-$k]=${color[$k]} 
		color[bg-$k]=${color[bg-black]} 
	done
	colour=(${(kv)color}) 
	local lc=$'\e[' rc=m 
	typeset -Hg reset_color bold_color
	reset_color="$lc${color[none]}$rc" 
	bold_color="$lc${color[bold]}$rc" 
	typeset -AHg fg fg_bold fg_no_bold
	for k in ${(k)color[(I)fg-*]}
	do
		fg[${k#fg-}]="$lc${color[$k]}$rc" 
		fg_bold[${k#fg-}]="$lc${color[bold]};${color[$k]}$rc" 
		fg_no_bold[${k#fg-}]="$lc${color[normal]};${color[$k]}$rc" 
	done
	typeset -AHg bg bg_bold bg_no_bold
	for k in ${(k)color[(I)bg-*]}
	do
		bg[${k#bg-}]="$lc${color[$k]}$rc" 
		bg_bold[${k#bg-}]="$lc${color[bold]};${color[$k]}$rc" 
		bg_no_bold[${k#bg-}]="$lc${color[normal]};${color[$k]}$rc" 
	done
}
compaudit () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
compdef () {
	local opt autol type func delete eval new i ret=0 cmd svc 
	local -a match mbegin mend
	emulate -L zsh
	setopt extendedglob
	if (( ! $# ))
	then
		print -u2 "$0: I need arguments"
		return 1
	fi
	while getopts "anpPkKde" opt
	do
		case "$opt" in
			(a) autol=yes  ;;
			(n) new=yes  ;;
			([pPkK]) if [[ -n "$type" ]]
				then
					print -u2 "$0: type already set to $type"
					return 1
				fi
				if [[ "$opt" = p ]]
				then
					type=pattern 
				elif [[ "$opt" = P ]]
				then
					type=postpattern 
				elif [[ "$opt" = K ]]
				then
					type=widgetkey 
				else
					type=key 
				fi ;;
			(d) delete=yes  ;;
			(e) eval=yes  ;;
		esac
	done
	shift OPTIND-1
	if (( ! $# ))
	then
		print -u2 "$0: I need arguments"
		return 1
	fi
	if [[ -z "$delete" ]]
	then
		if [[ -z "$eval" ]] && [[ "$1" = *\=* ]]
		then
			while (( $# ))
			do
				if [[ "$1" = *\=* ]]
				then
					cmd="${1%%\=*}" 
					svc="${1#*\=}" 
					func="$_comps[${_services[(r)$svc]:-$svc}]" 
					[[ -n ${_services[$svc]} ]] && svc=${_services[$svc]} 
					[[ -z "$func" ]] && func="${${_patcomps[(K)$svc][1]}:-${_postpatcomps[(K)$svc][1]}}" 
					if [[ -n "$func" ]]
					then
						_comps[$cmd]="$func" 
						_services[$cmd]="$svc" 
					else
						print -u2 "$0: unknown command or service: $svc"
						ret=1 
					fi
				else
					print -u2 "$0: invalid argument: $1"
					ret=1 
				fi
				shift
			done
			return ret
		fi
		func="$1" 
		[[ -n "$autol" ]] && autoload -rUz "$func"
		shift
		case "$type" in
			(widgetkey) while [[ -n $1 ]]
				do
					if [[ $# -lt 3 ]]
					then
						print -u2 "$0: compdef -K requires <widget> <comp-widget> <key>"
						return 1
					fi
					[[ $1 = _* ]] || 1="_$1" 
					[[ $2 = .* ]] || 2=".$2" 
					[[ $2 = .menu-select ]] && zmodload -i zsh/complist
					zle -C "$1" "$2" "$func"
					if [[ -n $new ]]
					then
						bindkey "$3" | IFS=$' \t' read -A opt
						[[ $opt[-1] = undefined-key ]] && bindkey "$3" "$1"
					else
						bindkey "$3" "$1"
					fi
					shift 3
				done ;;
			(key) if [[ $# -lt 2 ]]
				then
					print -u2 "$0: missing keys"
					return 1
				fi
				if [[ $1 = .* ]]
				then
					[[ $1 = .menu-select ]] && zmodload -i zsh/complist
					zle -C "$func" "$1" "$func"
				else
					[[ $1 = menu-select ]] && zmodload -i zsh/complist
					zle -C "$func" ".$1" "$func"
				fi
				shift
				for i
				do
					if [[ -n $new ]]
					then
						bindkey "$i" | IFS=$' \t' read -A opt
						[[ $opt[-1] = undefined-key ]] || continue
					fi
					bindkey "$i" "$func"
				done ;;
			(*) while (( $# ))
				do
					if [[ "$1" = -N ]]
					then
						type=normal 
					elif [[ "$1" = -p ]]
					then
						type=pattern 
					elif [[ "$1" = -P ]]
					then
						type=postpattern 
					else
						case "$type" in
							(pattern) if [[ $1 = (#b)(*)=(*) ]]
								then
									_patcomps[$match[1]]="=$match[2]=$func" 
								else
									_patcomps[$1]="$func" 
								fi ;;
							(postpattern) if [[ $1 = (#b)(*)=(*) ]]
								then
									_postpatcomps[$match[1]]="=$match[2]=$func" 
								else
									_postpatcomps[$1]="$func" 
								fi ;;
							(*) if [[ "$1" = *\=* ]]
								then
									cmd="${1%%\=*}" 
									svc=yes 
								else
									cmd="$1" 
									svc= 
								fi
								if [[ -z "$new" || -z "${_comps[$1]}" ]]
								then
									_comps[$cmd]="$func" 
									[[ -n "$svc" ]] && _services[$cmd]="${1#*\=}" 
								fi ;;
						esac
					fi
					shift
				done ;;
		esac
	else
		case "$type" in
			(pattern) unset "_patcomps[$^@]" ;;
			(postpattern) unset "_postpatcomps[$^@]" ;;
			(key) print -u2 "$0: cannot restore key bindings"
				return 1 ;;
			(*) unset "_comps[$^@]" ;;
		esac
	fi
}
compdump () {
	# undefined
	builtin autoload -XUz
}
compgen () {
	local opts prefix suffix job OPTARG OPTIND ret=1 
	local -a name res results jids
	local -A shortopts
	emulate -L sh
	setopt kshglob noshglob braceexpand nokshautoload
	shortopts=(a alias b builtin c command d directory e export f file g group j job k keyword u user v variable) 
	while getopts "o:A:G:C:F:P:S:W:X:abcdefgjkuv" name
	do
		case $name in
			([abcdefgjkuv]) OPTARG="${shortopts[$name]}"  ;&
			(A) case $OPTARG in
					(alias) results+=("${(k)aliases[@]}")  ;;
					(arrayvar) results+=("${(k@)parameters[(R)array*]}")  ;;
					(binding) results+=("${(k)widgets[@]}")  ;;
					(builtin) results+=("${(k)builtins[@]}" "${(k)dis_builtins[@]}")  ;;
					(command) results+=("${(k)commands[@]}" "${(k)aliases[@]}" "${(k)builtins[@]}" "${(k)functions[@]}" "${(k)reswords[@]}")  ;;
					(directory) setopt bareglobqual
						results+=(${IPREFIX}${PREFIX}*${SUFFIX}${ISUFFIX}(N-/)) 
						setopt nobareglobqual ;;
					(disabled) results+=("${(k)dis_builtins[@]}")  ;;
					(enabled) results+=("${(k)builtins[@]}")  ;;
					(export) results+=("${(k)parameters[(R)*export*]}")  ;;
					(file) setopt bareglobqual
						results+=(${IPREFIX}${PREFIX}*${SUFFIX}${ISUFFIX}(N)) 
						setopt nobareglobqual ;;
					(function) results+=("${(k)functions[@]}")  ;;
					(group) emulate zsh
						_groups -U -O res
						emulate sh
						setopt kshglob noshglob braceexpand
						results+=("${res[@]}")  ;;
					(hostname) emulate zsh
						_hosts -U -O res
						emulate sh
						setopt kshglob noshglob braceexpand
						results+=("${res[@]}")  ;;
					(job) results+=("${savejobtexts[@]%% *}")  ;;
					(keyword) results+=("${(k)reswords[@]}")  ;;
					(running) jids=("${(@k)savejobstates[(R)running*]}") 
						for job in "${jids[@]}"
						do
							results+=(${savejobtexts[$job]%% *}) 
						done ;;
					(stopped) jids=("${(@k)savejobstates[(R)suspended*]}") 
						for job in "${jids[@]}"
						do
							results+=(${savejobtexts[$job]%% *}) 
						done ;;
					(setopt | shopt) results+=("${(k)options[@]}")  ;;
					(signal) results+=("SIG${^signals[@]}")  ;;
					(user) results+=("${(k)userdirs[@]}")  ;;
					(variable) results+=("${(k)parameters[@]}")  ;;
					(helptopic)  ;;
				esac ;;
			(F) COMPREPLY=() 
				local -a args
				args=("${words[0]}" "${@[-1]}" "${words[CURRENT-2]}") 
				() {
					typeset -h words
					$OPTARG "${args[@]}"
				}
				results+=("${COMPREPLY[@]}")  ;;
			(G) setopt nullglob
				results+=(${~OPTARG}) 
				unsetopt nullglob ;;
			(W) results+=(${(Q)~=OPTARG})  ;;
			(C) results+=($(eval $OPTARG))  ;;
			(P) prefix="$OPTARG"  ;;
			(S) suffix="$OPTARG"  ;;
			(X) if [[ ${OPTARG[0]} = '!' ]]
				then
					results=("${(M)results[@]:#${OPTARG#?}}") 
				else
					results=("${results[@]:#$OPTARG}") 
				fi ;;
		esac
	done
	print -l -r -- "$prefix${^results[@]}$suffix"
}
compinit () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
compinstall () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
complete () {
	emulate -L zsh
	local args void cmd print remove
	args=("$@") 
	zparseopts -D -a void o: A: G: W: C: F: P: S: X: a b c d e f g j k u v p=print r=remove
	if [[ -n $print ]]
	then
		printf 'complete %2$s %1$s\n' "${(@kv)_comps[(R)_bash*]#* }"
	elif [[ -n $remove ]]
	then
		for cmd
		do
			unset "_comps[$cmd]"
		done
	else
		compdef _bash_complete\ ${(j. .)${(q)args[1,-1-$#]}} "$@"
	fi
}
convert_mp4_to_gif () {
	if [[ -z "$1" ]]
	then
		echo "Usage: convert_mp4_to_gif <input_file.mp4>"
		return 1
	fi
	local input_file=$1 
	if [[ "${input_file: -4}" != ".mp4" ]]
	then
		echo "The input file must be a .mp4 file."
		return 1
	fi
	local output_file="${input_file%.mp4}.gif" 
	ffmpeg-bar -y -i "$input_file" -r 15 -vf "scale=720:-1" -ss 00:00:00 -to 00:00:10 "$output_file"
	echo "GIF created: $output_file"
}
current_branch () {
	git_current_branch
}
d () {
	if [[ -n $1 ]]
	then
		dirs "$@"
	else
		dirs -v | head -n 10
	fi
}
deactivate () {
	unset -f pydoc > /dev/null 2>&1 || true
	if ! [ -z "${_OLD_VIRTUAL_PATH:+_}" ]
	then
		PATH="$_OLD_VIRTUAL_PATH" 
		export PATH
		unset _OLD_VIRTUAL_PATH
	fi
	if ! [ -z "${_OLD_VIRTUAL_PYTHONHOME+_}" ]
	then
		PYTHONHOME="$_OLD_VIRTUAL_PYTHONHOME" 
		export PYTHONHOME
		unset _OLD_VIRTUAL_PYTHONHOME
	fi
	hash -r 2> /dev/null
	if ! [ -z "${_OLD_VIRTUAL_PS1+_}" ]
	then
		PS1="$_OLD_VIRTUAL_PS1" 
		export PS1
		unset _OLD_VIRTUAL_PS1
	fi
	unset VIRTUAL_ENV
	unset VIRTUAL_ENV_PROMPT
	if [ ! "${1-}" = "nondestructive" ]
	then
		unset -f deactivate
	fi
}
default () {
	(( $+parameters[$1] )) && return 0
	typeset -g "$1"="$2" && return 3
}
delete_line_with_fzf () {
	local file="$1" 
	if [[ ! -f "$file" ]]
	then
		echo "文件 $file 不存在"
		return 1
	fi
	local selected_line=$(cat "$file" | fzf) 
	if [[ -n "$selected_line" ]]
	then
		echo "上下文行："
		grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox} -C 1 -F "$selected_line" "$file" | sed "s/$selected_line/\x1b[31m&\x1b[0m/"
		local temp_file=$(mktemp) 
		grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox} -vF "$selected_line" "$file" > "$temp_file"
		if [[ $? -eq 0 ]]
		then
			mv -iv "$temp_file" "$file"
			echo -e "\n已刪除的行：\x1b[31m$selected_line\x1b[0m"
		else
			echo "刪除過程中發生錯誤"
			rm -i "$temp_file"
			return 1
		fi
	else
		echo "未選定任何行"
	fi
}
detect-clipboard () {
	emulate -L zsh
	if [[ "${OSTYPE}" == darwin* ]] && (( ${+commands[pbcopy]} )) && (( ${+commands[pbpaste]} ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | pbcopy
		}
		clippaste () {
			pbpaste
		}
	elif [[ "${OSTYPE}" == (cygwin|msys)* ]]
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" > /dev/clipboard
		}
		clippaste () {
			cat /dev/clipboard
		}
	elif (( $+commands[clip.exe] )) && (( $+commands[powershell.exe] ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | clip.exe
		}
		clippaste () {
			powershell.exe -noprofile -command Get-Clipboard
		}
	elif [ -n "${WAYLAND_DISPLAY:-}" ] && (( ${+commands[wl-copy]} )) && (( ${+commands[wl-paste]} ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | wl-copy &> /dev/null &|
		}
		clippaste () {
			wl-paste
		}
	elif [ -n "${DISPLAY:-}" ] && (( ${+commands[xsel]} ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | xsel --clipboard --input
		}
		clippaste () {
			xsel --clipboard --output
		}
	elif [ -n "${DISPLAY:-}" ] && (( ${+commands[xclip]} ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | xclip -selection clipboard -in &> /dev/null &|
		}
		clippaste () {
			xclip -out -selection clipboard
		}
	elif (( ${+commands[lemonade]} ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | lemonade copy
		}
		clippaste () {
			lemonade paste
		}
	elif (( ${+commands[doitclient]} ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | doitclient wclip
		}
		clippaste () {
			doitclient wclip -r
		}
	elif (( ${+commands[win32yank]} ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | win32yank -i
		}
		clippaste () {
			win32yank -o
		}
	elif [[ $OSTYPE == linux-android* ]] && (( $+commands[termux-clipboard-set] ))
	then
		clipcopy () {
			cat "${1:-/dev/stdin}" | termux-clipboard-set
		}
		clippaste () {
			termux-clipboard-get
		}
	elif [ -n "${TMUX:-}" ] && (( ${+commands[tmux]} ))
	then
		clipcopy () {
			tmux load-buffer "${1:--}"
		}
		clippaste () {
			tmux save-buffer -
		}
	else
		_retry_clipboard_detection_or_fail () {
			local clipcmd="${1}" 
			shift
			if detect-clipboard
			then
				"${clipcmd}" "$@"
			else
				print "${clipcmd}: Platform $OSTYPE not supported or xclip/xsel not installed" >&2
				return 1
			fi
		}
		clipcopy () {
			_retry_clipboard_detection_or_fail clipcopy "$@"
		}
		clippaste () {
			_retry_clipboard_detection_or_fail clippaste "$@"
		}
		return 1
	fi
}
dia () {
	(
		python3 ~/pyscripts/inbox.py &
	)
	local filename="$HOME/Dropbox/inbox/$(date +"%Y-%m-%d").md" 
	if [ -e "$filename" ]
	then
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
		} >> "$filename"
		nvim +13 "$filename"
	fi
}
diff () {
	command diff --color "$@"
}
dotpull () {
	git restore $DOTFILES
	git -C $DOTFILES pull
}
down-line-or-beginning-search () {
	# undefined
	builtin autoload -XU
}
dp () {
	cd $DOTFILES
	git -C $DOTFILES add .
	aicommits
	git -C $DOTFILES push
	cd -
}
draft () {
	cd "$HOME/Dropbox/blog/"
	local filename="$HOME/Dropbox/blog/$(date +"%Y-%m-%d-%H-%M").md" 
	if [ -e "$filename" ]
	then
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
drafts () {
	cd ~/Dropbox/blog/
	FILE=$(find . -type f -name "*.md" | sed 's|^\./||' | fzf) 
	if [ -n "$FILE" ]
	then
		nvim +8 "$FILE"
	else
		echo "Do you want to create a new draft? [y/n]"
		read answer
		if [[ $answer == "y" ]]
		then
			draft
		else
			echo "一隻鳥接著一隻鳥寫就對了！"
		fi
	fi
}
edit-command-line () {
	# undefined
	builtin autoload -XU
}
env_default () {
	[[ ${parameters[$1]} = *-export* ]] && return 0
	export "$1=$2" && return 3
}
fast-theme () {
	# undefined
	builtin autoload -XUz
}
fcd () {
	local dir
	dir=$(fd --type d | fzf)  && cd "$dir"
}
fnm () {
	lazyload fnm node npm -- $'_load_fnm' && fnm "$@"
}
fzf-pre () {
	fzf -m --height 50% --layout=reverse --inline-info --preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200' --preview-window 'right,50%,+{2}+3/3,~3,noborder' --bind '?:toggle-preview'
}
gccd () {
	command git clone --recurse-submodules "$@"
	[[ -d "$_" ]] && cd "$_" || cd "${${_:t}%.git}"
}
gdnolock () {
	git diff "$@" ":(exclude)package-lock.json" ":(exclude)*.lock"
}
gdv () {
	git diff -w "$@" | view -
}
getColorCode () {
	eval "$__p9k_intro"
	if (( ARGC == 1 ))
	then
		case $1 in
			(foreground) local k
				for k in "${(k@)__p9k_colors}"
				do
					local v=${__p9k_colors[$k]} 
					print -rP -- "%F{$v}$v - $k%f"
				done
				return 0 ;;
			(background) local k
				for k in "${(k@)__p9k_colors}"
				do
					local v=${__p9k_colors[$k]} 
					print -rP -- "%K{$v}$v - $k%k"
				done
				return 0 ;;
		esac
	fi
	echo "Usage: getColorCode background|foreground" >&2
	return 1
}
get_icon_names () {
	eval "$__p9k_intro"
	_p9k_init_icons
	local key
	for key in ${(@kon)icons}
	do
		echo -n - "POWERLEVEL9K_$key: "
		print -nP "%K{red} %k"
		if [[ $1 == original ]]
		then
			echo -n - $icons[$key]
		else
			print_icon $key
		fi
		print -P "%K{red} %k"
	done
}
getent () {
	if [[ $1 = hosts ]]
	then
		sed 's/#.*//' /etc/$1 | grep -w $2
	elif [[ $2 = <-> ]]
	then
		grep ":$2:[^:]*$" /etc/$1
	else
		grep "^$2:" /etc/$1
	fi
}
ggf () {
	[[ "$#" != 1 ]] && local b="$(git_current_branch)" 
	git push --force origin "${b:=$1}"
}
ggfl () {
	[[ "$#" != 1 ]] && local b="$(git_current_branch)" 
	git push --force-with-lease origin "${b:=$1}"
}
ggl () {
	if [[ "$#" != 0 ]] && [[ "$#" != 1 ]]
	then
		git pull origin "${*}"
	else
		[[ "$#" == 0 ]] && local b="$(git_current_branch)" 
		git pull origin "${b:=$1}"
	fi
}
ggp () {
	if [[ "$#" != 0 ]] && [[ "$#" != 1 ]]
	then
		git push origin "${*}"
	else
		[[ "$#" == 0 ]] && local b="$(git_current_branch)" 
		git push origin "${b:=$1}"
	fi
}
ggpnp () {
	if [[ "$#" == 0 ]]
	then
		ggl && ggp
	else
		ggl "${*}" && ggp "${*}"
	fi
}
ggu () {
	[[ "$#" != 1 ]] && local b="$(git_current_branch)" 
	git pull --rebase origin "${b:=$1}"
}
gist () {
	MY_FILE=$1 
	DESCRIPTION=$(cat "$MY_FILE" | grep -iE 'description:|desc:' | cut -d':' -f2 | tr -d '"') 
	op plugin run -- gh gist create "$MY_FILE" --desc "$DESCRIPTION"
}
git_commits_ahead () {
	if __git_prompt_git rev-parse --git-dir &> /dev/null
	then
		local commits="$(__git_prompt_git rev-list --count @{upstream}..HEAD 2>/dev/null)" 
		if [[ -n "$commits" && "$commits" != 0 ]]
		then
			echo "$ZSH_THEME_GIT_COMMITS_AHEAD_PREFIX$commits$ZSH_THEME_GIT_COMMITS_AHEAD_SUFFIX"
		fi
	fi
}
git_commits_behind () {
	if __git_prompt_git rev-parse --git-dir &> /dev/null
	then
		local commits="$(__git_prompt_git rev-list --count HEAD..@{upstream} 2>/dev/null)" 
		if [[ -n "$commits" && "$commits" != 0 ]]
		then
			echo "$ZSH_THEME_GIT_COMMITS_BEHIND_PREFIX$commits$ZSH_THEME_GIT_COMMITS_BEHIND_SUFFIX"
		fi
	fi
}
git_current_branch () {
	local ref
	ref=$(__git_prompt_git symbolic-ref --quiet HEAD 2> /dev/null) 
	local ret=$? 
	if [[ $ret != 0 ]]
	then
		[[ $ret == 128 ]] && return
		ref=$(__git_prompt_git rev-parse --short HEAD 2> /dev/null)  || return
	fi
	echo ${ref#refs/heads/}
}
git_current_user_email () {
	__git_prompt_git config user.email 2> /dev/null
}
git_current_user_name () {
	__git_prompt_git config user.name 2> /dev/null
}
git_develop_branch () {
	command git rev-parse --git-dir &> /dev/null || return
	local branch
	for branch in dev devel development
	do
		if command git show-ref -q --verify refs/heads/$branch
		then
			echo $branch
			return
		fi
	done
	echo develop
}
git_main_branch () {
	command git rev-parse --git-dir &> /dev/null || return
	local ref
	for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default}
	do
		if command git show-ref -q --verify $ref
		then
			echo ${ref:t}
			return
		fi
	done
	echo master
}
git_prompt_ahead () {
	if [[ -n "$(__git_prompt_git rev-list origin/$(git_current_branch)..HEAD 2> /dev/null)" ]]
	then
		echo "$ZSH_THEME_GIT_PROMPT_AHEAD"
	fi
}
git_prompt_behind () {
	if [[ -n "$(__git_prompt_git rev-list HEAD..origin/$(git_current_branch) 2> /dev/null)" ]]
	then
		echo "$ZSH_THEME_GIT_PROMPT_BEHIND"
	fi
}
git_prompt_info () {
	if ! __git_prompt_git rev-parse --git-dir &> /dev/null || [[ "$(__git_prompt_git config --get oh-my-zsh.hide-info 2>/dev/null)" == 1 ]]
	then
		return 0
	fi
	local ref
	ref=$(__git_prompt_git symbolic-ref --short HEAD 2> /dev/null)  || ref=$(__git_prompt_git describe --tags --exact-match HEAD 2> /dev/null)  || ref=$(__git_prompt_git rev-parse --short HEAD 2> /dev/null)  || return 0
	local upstream
	if (( ${+ZSH_THEME_GIT_SHOW_UPSTREAM} ))
	then
		upstream=$(__git_prompt_git rev-parse --abbrev-ref --symbolic-full-name "@{upstream}" 2>/dev/null)  && upstream=" -> ${upstream}" 
	fi
	echo "${ZSH_THEME_GIT_PROMPT_PREFIX}${ref:gs/%/%%}${upstream:gs/%/%%}$(parse_git_dirty)${ZSH_THEME_GIT_PROMPT_SUFFIX}"
}
git_prompt_long_sha () {
	local SHA
	SHA=$(__git_prompt_git rev-parse HEAD 2> /dev/null)  && echo "$ZSH_THEME_GIT_PROMPT_SHA_BEFORE$SHA$ZSH_THEME_GIT_PROMPT_SHA_AFTER"
}
git_prompt_remote () {
	if [[ -n "$(__git_prompt_git show-ref origin/$(git_current_branch) 2> /dev/null)" ]]
	then
		echo "$ZSH_THEME_GIT_PROMPT_REMOTE_EXISTS"
	else
		echo "$ZSH_THEME_GIT_PROMPT_REMOTE_MISSING"
	fi
}
git_prompt_short_sha () {
	local SHA
	SHA=$(__git_prompt_git rev-parse --short HEAD 2> /dev/null)  && echo "$ZSH_THEME_GIT_PROMPT_SHA_BEFORE$SHA$ZSH_THEME_GIT_PROMPT_SHA_AFTER"
}
git_prompt_status () {
	[[ "$(__git_prompt_git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]] && return
	local -A prefix_constant_map
	prefix_constant_map=('\?\? ' 'UNTRACKED' 'A  ' 'ADDED' 'M  ' 'ADDED' 'MM ' 'MODIFIED' ' M ' 'MODIFIED' 'AM ' 'MODIFIED' ' T ' 'MODIFIED' 'R  ' 'RENAMED' ' D ' 'DELETED' 'D  ' 'DELETED' 'UU ' 'UNMERGED' 'ahead' 'AHEAD' 'behind' 'BEHIND' 'diverged' 'DIVERGED' 'stashed' 'STASHED') 
	local -A constant_prompt_map
	constant_prompt_map=('UNTRACKED' "$ZSH_THEME_GIT_PROMPT_UNTRACKED" 'ADDED' "$ZSH_THEME_GIT_PROMPT_ADDED" 'MODIFIED' "$ZSH_THEME_GIT_PROMPT_MODIFIED" 'RENAMED' "$ZSH_THEME_GIT_PROMPT_RENAMED" 'DELETED' "$ZSH_THEME_GIT_PROMPT_DELETED" 'UNMERGED' "$ZSH_THEME_GIT_PROMPT_UNMERGED" 'AHEAD' "$ZSH_THEME_GIT_PROMPT_AHEAD" 'BEHIND' "$ZSH_THEME_GIT_PROMPT_BEHIND" 'DIVERGED' "$ZSH_THEME_GIT_PROMPT_DIVERGED" 'STASHED' "$ZSH_THEME_GIT_PROMPT_STASHED") 
	local status_constants
	status_constants=(UNTRACKED ADDED MODIFIED RENAMED DELETED STASHED UNMERGED AHEAD BEHIND DIVERGED) 
	local status_text
	status_text="$(__git_prompt_git status --porcelain -b 2> /dev/null)" 
	if [[ $? -eq 128 ]]
	then
		return 1
	fi
	local -A statuses_seen
	if __git_prompt_git rev-parse --verify refs/stash &> /dev/null
	then
		statuses_seen[STASHED]=1 
	fi
	local status_lines
	status_lines=("${(@f)${status_text}}") 
	if [[ "$status_lines[1]" =~ "^## [^ ]+ \[(.*)\]" ]]
	then
		local branch_statuses
		branch_statuses=("${(@s/,/)match}") 
		for branch_status in $branch_statuses
		do
			if [[ ! $branch_status =~ "(behind|diverged|ahead) ([0-9]+)?" ]]
			then
				continue
			fi
			local last_parsed_status=$prefix_constant_map[$match[1]] 
			statuses_seen[$last_parsed_status]=$match[2] 
		done
	fi
	for status_prefix in ${(k)prefix_constant_map}
	do
		local status_constant="${prefix_constant_map[$status_prefix]}" 
		local status_regex=$'(^|\n)'"$status_prefix" 
		if [[ "$status_text" =~ $status_regex ]]
		then
			statuses_seen[$status_constant]=1 
		fi
	done
	local status_prompt
	for status_constant in $status_constants
	do
		if (( ${+statuses_seen[$status_constant]} ))
		then
			local next_display=$constant_prompt_map[$status_constant] 
			status_prompt="$next_display$status_prompt" 
		fi
	done
	echo $status_prompt
}
git_remote_status () {
	local remote ahead behind git_remote_status git_remote_status_detailed
	remote=${$(__git_prompt_git rev-parse --verify ${hook_com[branch]}@{upstream} --symbolic-full-name 2>/dev/null)/refs\/remotes\/} 
	if [[ -n ${remote} ]]
	then
		ahead=$(__git_prompt_git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l) 
		behind=$(__git_prompt_git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l) 
		if [[ $ahead -eq 0 ]] && [[ $behind -eq 0 ]]
		then
			git_remote_status="$ZSH_THEME_GIT_PROMPT_EQUAL_REMOTE" 
		elif [[ $ahead -gt 0 ]] && [[ $behind -eq 0 ]]
		then
			git_remote_status="$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE" 
			git_remote_status_detailed="$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE_COLOR$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE$((ahead))%{$reset_color%}" 
		elif [[ $behind -gt 0 ]] && [[ $ahead -eq 0 ]]
		then
			git_remote_status="$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE" 
			git_remote_status_detailed="$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE_COLOR$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE$((behind))%{$reset_color%}" 
		elif [[ $ahead -gt 0 ]] && [[ $behind -gt 0 ]]
		then
			git_remote_status="$ZSH_THEME_GIT_PROMPT_DIVERGED_REMOTE" 
			git_remote_status_detailed="$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE_COLOR$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE$((ahead))%{$reset_color%}$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE_COLOR$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE$((behind))%{$reset_color%}" 
		fi
		if [[ -n $ZSH_THEME_GIT_PROMPT_REMOTE_STATUS_DETAILED ]]
		then
			git_remote_status="$ZSH_THEME_GIT_PROMPT_REMOTE_STATUS_PREFIX${remote:gs/%/%%}$git_remote_status_detailed$ZSH_THEME_GIT_PROMPT_REMOTE_STATUS_SUFFIX" 
		fi
		echo $git_remote_status
	fi
}
git_repo_name () {
	local repo_path
	if repo_path="$(__git_prompt_git rev-parse --show-toplevel 2>/dev/null)"  && [[ -n "$repo_path" ]]
	then
		echo ${repo_path:t}
	fi
}
gitacp () {
	git add .
	aicommits
	git push
}
gitop () {
	if git rev-parse --show-toplevel > /dev/null 2>&1
	then
		cd "$(git rev-parse --show-toplevel)"
	else
		echo "\033[31mNot in a git repository\033[0m"
	fi
}
grename () {
	if [[ -z "$1" || -z "$2" ]]
	then
		echo "Usage: $0 old_branch new_branch"
		return 1
	fi
	git branch -m "$1" "$2"
	if git push origin :"$1"
	then
		git push --set-upstream origin "$2"
	fi
}
gunwipall () {
	local _commit=$(git log --grep='--wip--' --invert-grep --max-count=1 --format=format:%H) 
	if [[ "$_commit" != "$(git rev-parse HEAD)" ]]
	then
		git reset $_commit || return 1
	fi
}
handle_completion_insecurities () {
	local -aU insecure_dirs
	insecure_dirs=(${(f@):-"$(compaudit 2>/dev/null)"}) 
	[[ -z "${insecure_dirs}" ]] && return
	print "[oh-my-zsh] Insecure completion-dependent directories detected:"
	ls -ld "${(@)insecure_dirs}"
	cat <<EOD

[oh-my-zsh] For safety, we will not load completions from these directories until
[oh-my-zsh] you fix their permissions and ownership and restart zsh.
[oh-my-zsh] See the above list for directories with group or other writability.

[oh-my-zsh] To fix your permissions you can do so by disabling
[oh-my-zsh] the write permission of "group" and "others" and making sure that the
[oh-my-zsh] owner of these directories is either root or your current user.
[oh-my-zsh] The following command may help:
[oh-my-zsh]     compaudit | xargs chmod g-w,o-w

[oh-my-zsh] If the above didn't help or you want to skip the verification of
[oh-my-zsh] insecure directories you can set the variable ZSH_DISABLE_COMPFIX to
[oh-my-zsh] "true" before oh-my-zsh is sourced in your zshrc file.

EOD
}
hg_prompt_info () {
	return 1
}
hh () {
	cd ~/Dropbox/
	(
		python3 ~/Dropbox/scripts/gen_recent_list.py &
	)
	FILE=$(find . -type f -name "*.md" | sed 's|^\./||' | fzf-pre) 
	if [ -n "$FILE" ]
	then
		nvim +10 "$FILE"
	else
		cd ~/Dropbox/Medical/
		echo "獨學而無友，則孤陋而寡聞"
	fi
}
icdn () {
	GREEN="\033[32m" 
	RESET="\033[0m" 
	echo "The following files are in the cloud nine:"
	find . -name '.*icloud'
	find . -name '.*icloud' | perl -pe 's|(.*)/.(.*).icloud|$1/$2|s' | while read file
	do
		brctl download "$file"
	done
	echo "\n${GREEN}Start to download all the files, be patient! ⏱️ ${RESET}"
}
icloudownload () {
	if ! command -v find > /dev/null
	then
		echo "❌ 'find' is not installed. Please install it first."
		return 1
	fi
	if [[ -z "$1" ]]
	then
		echo "📂 Usage: icloudownload /path/to/icloud/file_or_folder"
		return 1
	fi
	local target="$1" 
	if [[ -f "$target" ]]
	then
		local size=$(stat -f%z "$target") 
		echo -ne "📄 [1/1] Processing: $target (${size} bytes) \r"
		head -c 1 "$target" > /dev/null
		echo -e "✅ Done: $target (${size} bytes)                    "
	elif [[ -d "$target" ]]
	then
		local IFS=$'\n' 
		local files=($(find "$target" -type f)) 
		local total=${#files[@]} 
		local count=0 
		for file in "${files[@]}"
		do
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
ignore_dropbox_file () {
	local filepath
	filepath=$(find "$HOME/Library/CloudStorage/Dropbox" -type f | fzf) 
	[ -n "$filepath" ] && xattr -w 'com.apple.fileprovider.ignore#P' 1 "$filepath"
}
ignore_dropbox_folder () {
	local folderpath
	echo "🔍 選擇要忽略的 Dropbox 資料夾..."
	folderpath=$(find "$HOME/Library/CloudStorage/Dropbox" -type d | fzf) 
	if [ -n "$folderpath" ]
	then
		xattr -w 'com.apple.fileprovider.ignore#P' 1 "$folderpath"
		echo "✅ 成功忽略：$folderpath"
	else
		echo "❌ 未選擇資料夾"
	fi
}
inbox () {
	cd ~/Dropbox/inbox/
	python3 ~/pyscripts/inbox.py
	nvim +10 ~/Dropbox/inbox/index.md
}
instant_prompt__p9k_internal_nothing () {
	prompt__p9k_internal_nothing
}
instant_prompt_context () {
	if [[ $_POWERLEVEL9K_ALWAYS_SHOW_CONTEXT == 0 && -n $DEFAULT_USER && $P9K_SSH == 0 ]]
	then
		if [[ ${(%):-%n} == $DEFAULT_USER ]]
		then
			if (( ! _POWERLEVEL9K_ALWAYS_SHOW_USER ))
			then
				return
			fi
		fi
	fi
	prompt_context
}
instant_prompt_date () {
	_p9k_escape $_POWERLEVEL9K_DATE_FORMAT
	local stash='${${__p9k_instant_prompt_date::=${(%)${__p9k_instant_prompt_date_format::='$_p9k__ret'}}}+}' 
	_p9k_escape $_POWERLEVEL9K_DATE_FORMAT
	_p9k_prompt_segment prompt_date "$_p9k_color2" "$_p9k_color1" "DATE_ICON" 1 '' $stash$_p9k__ret
}
instant_prompt_dir () {
	prompt_dir
}
instant_prompt_dir_writable () {
	prompt_dir_writable
}
instant_prompt_direnv () {
	if [[ -n ${DIRENV_DIR:-} && $precmd_functions[-1] == _p9k_precmd ]]
	then
		_p9k_prompt_segment prompt_direnv $_p9k_color1 yellow DIRENV_ICON 0 '' ''
	fi
}
instant_prompt_example () {
	prompt_example
}
instant_prompt_host () {
	prompt_host
}
instant_prompt_midnight_commander () {
	_p9k_prompt_segment prompt_midnight_commander $_p9k_color1 yellow MIDNIGHT_COMMANDER_ICON 0 '$MC_TMPDIR' ''
}
instant_prompt_nix_shell () {
	_p9k_prompt_segment prompt_nix_shell 4 $_p9k_color1 NIX_SHELL_ICON 1 '${IN_NIX_SHELL:#0}' '${(M)IN_NIX_SHELL:#(pure|impure)}'
}
instant_prompt_nnn () {
	_p9k_prompt_segment prompt_nnn 6 $_p9k_color1 NNN_ICON 1 '${NNNLVL:#0}' '$NNNLVL'
}
instant_prompt_os_icon () {
	prompt_os_icon
}
instant_prompt_prompt_char () {
	_p9k_prompt_segment prompt_prompt_char_OK_VIINS "$_p9k_color1" 76 '' 0 '' '❯'
}
instant_prompt_ranger () {
	_p9k_prompt_segment prompt_ranger $_p9k_color1 yellow RANGER_ICON 1 '$RANGER_LEVEL' '$RANGER_LEVEL'
}
instant_prompt_root_indicator () {
	prompt_root_indicator
}
instant_prompt_ssh () {
	if (( ! P9K_SSH ))
	then
		return
	fi
	prompt_ssh
}
instant_prompt_status () {
	if (( _POWERLEVEL9K_STATUS_OK ))
	then
		_p9k_prompt_segment prompt_status_OK "$_p9k_color1" green OK_ICON 0 '' ''
	fi
}
instant_prompt_time () {
	_p9k_escape $_POWERLEVEL9K_TIME_FORMAT
	local stash='${${__p9k_instant_prompt_time::=${(%)${__p9k_instant_prompt_time_format::='$_p9k__ret'}}}+}' 
	_p9k_escape $_POWERLEVEL9K_TIME_FORMAT
	_p9k_prompt_segment prompt_time "$_p9k_color2" "$_p9k_color1" "TIME_ICON" 1 '' $stash$_p9k__ret
}
instant_prompt_toolbox () {
	_p9k_prompt_segment prompt_toolbox $_p9k_color1 yellow TOOLBOX_ICON 1 '$P9K_TOOLBOX_NAME' '$P9K_TOOLBOX_NAME'
}
instant_prompt_user () {
	if [[ $_POWERLEVEL9K_ALWAYS_SHOW_USER == 0 && "${(%):-%n}" == $DEFAULT_USER ]]
	then
		return
	fi
	prompt_user
}
instant_prompt_vi_mode () {
	if [[ -n $_POWERLEVEL9K_VI_INSERT_MODE_STRING ]]
	then
		_p9k_prompt_segment prompt_vi_mode_INSERT "$_p9k_color1" blue '' 0 '' "$_POWERLEVEL9K_VI_INSERT_MODE_STRING"
	fi
}
instant_prompt_vim_shell () {
	_p9k_prompt_segment prompt_vim_shell green $_p9k_color1 VIM_ICON 0 '$VIMRUNTIME' ''
}
instant_prompt_xplr () {
	_p9k_prompt_segment prompt_xplr 6 $_p9k_color1 XPLR_ICON 0 '$XPLR_PID' ''
}
is-at-least () {
	emulate -L zsh
	local IFS=".-" min_cnt=0 ver_cnt=0 part min_ver version order 
	min_ver=(${=1}) 
	version=(${=2:-$ZSH_VERSION} 0) 
	while (( $min_cnt <= ${#min_ver} ))
	do
		while [[ "$part" != <-> ]]
		do
			(( ++ver_cnt > ${#version} )) && return 0
			if [[ ${version[ver_cnt]} = *[0-9][^0-9]* ]]
			then
				order=(${version[ver_cnt]} ${min_ver[ver_cnt]}) 
				if [[ ${version[ver_cnt]} = <->* ]]
				then
					[[ $order != ${${(On)order}} ]] && return 1
				else
					[[ $order != ${${(O)order}} ]] && return 1
				fi
				[[ $order[1] != $order[2] ]] && return 0
			fi
			part=${version[ver_cnt]##*[^0-9]} 
		done
		while true
		do
			(( ++min_cnt > ${#min_ver} )) && return 0
			[[ ${min_ver[min_cnt]} = <-> ]] && break
		done
		(( part > min_ver[min_cnt] )) && return 0
		(( part < min_ver[min_cnt] )) && return 1
		part='' 
	done
}
is_git_repo () {
	git rev-parse --is-inside-work-tree &> /dev/null
}
is_plugin () {
	local base_dir=$1 
	local name=$2 
	builtin test -f $base_dir/plugins/$name/$name.plugin.zsh || builtin test -f $base_dir/plugins/$name/_$name
}
is_theme () {
	local base_dir=$1 
	local name=$2 
	builtin test -f $base_dir/$name.zsh-theme
}
jenv_prompt_info () {
	return 1
}
joinmp3 () {
	cd $1
	for f in ./*.mp3
	do
		echo "file '$f'" >> mylist.txt
	done
	ffmpeg-bar -y -f concat -safe 0 -i mylist.txt -c copy output.mp3
	cd -
}
joinmp4 () {
	for file in *.mp4
	do
		echo "$file: $(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$file") seconds"
	done
	for file in *.mp4
	do
		echo "file '$file'" >> filelist.txt
	done
	ffmpeg-bar -f concat -safe 0 -i filelist.txt -c copy combined_$1.mp4
}
joshuto_official () {
	ID="$$" 
	mkdir -p -p /tmp/$USER
	OUTPUT_FILE="/tmp/$USER/joshuto-cwd-$ID" 
	env joshuto --output-file "$OUTPUT_FILE" $@
	exit_code=$? 
	case "$exit_code" in
		(0)  ;;
		(101) JOSHUTO_CWD=$(cat "$OUTPUT_FILE") 
			cd "$JOSHUTO_CWD" ;;
		(102)  ;;
		(*) echo "Exit code: $exit_code" ;;
	esac
}
killmarp () {
	pkill -f marp
}
lazyload () {
	local seperator='--' 
	local seperator_index=${@[(ie)$seperator]} 
	local cmd_list=(${@:1:(($seperator_index - 1))}) 
	local load_cmd=${@[(($seperator_index + 1))]} 
	if [[ ! -n $load_cmd ]]
	then
		echo "[ERROR] lazyload: No load command defined" >&2
		echo "  $@" >&2
		return 1
	fi
	if (( ${cmd_list[(Ie)${funcstack[2]}]} ))
	then
		unfunction $cmd_list
		eval "$load_cmd"
	else
		local cmd
		for cmd in $cmd_list
		do
			eval "function $cmd { lazyload $cmd_list $seperator ${(qqqq)load_cmd} && $cmd \"\$@\" }"
		done
	fi
}
lfcd () {
	tmp="$(mktemp)" 
	command lf -last-dir-path="$tmp" "$@"
	if [ -f "$tmp" ]
	then
		dir="$(cat "$tmp")" 
		rm -i -f "$tmp"
		if [ -d "$dir" ]
		then
			if [ "$dir" != "$(pwd)" ]
			then
				cd "$dir"
			fi
		fi
	fi
}
make_exec_and_slide () {
	cd $HOME/Dropbox/slides/contents
	file=$(find . -type f -name "*.md" | sed 's|^\./||' | fzf-pre) 
	chmod +x "$file"
	slides "$file"
}
make_flashcard () {
	local dir=~/dropbox/flashcards 
	local timestamp=$(date +%Y%m%d%H%M%S) 
	local filepath="$dir/$timestamp.md" 
	mkdir -p -p "$dir" || {
		echo "❌ Failed to create directory: $dir"
		return 1
	}
	cat <<EOF > "$filepath"
# $timestamp

## Front

## Back

## Disease
EOF
	echo "✅ Flashcard created: $filepath"
	nvim "$filepath"
}
mediumog () {
	if [ $# -eq 0 ]
	then
		echo "Usage: mediumog <slide_name>"
		return 1
	fi
	local slide_name="$1" 
	sh ~/.dotfiles/shellscripts/gen_medium_og.sh "$slide_name"
}
mkcd () {
	mkdir -p -p "$@" && cd "$_"
}
my_git_formatter () {
	emulate -L zsh
	if [[ -n $P9K_CONTENT ]]
	then
		typeset -g my_git_format=$P9K_CONTENT 
		return
	fi
	if (( $1 ))
	then
		local meta='%f' 
		local clean='%76F' 
		local modified='%178F' 
		local untracked='%39F' 
		local conflicted='%196F' 
	else
		local meta='%244F' 
		local clean='%244F' 
		local modified='%244F' 
		local untracked='%244F' 
		local conflicted='%244F' 
	fi
	local res
	if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]
	then
		local branch=${(V)VCS_STATUS_LOCAL_BRANCH} 
		(( $#branch > 32 )) && branch[13,-13]="…" 
		res+="${clean}${(g::)POWERLEVEL9K_VCS_BRANCH_ICON}${branch//\%/%%}" 
	fi
	if [[ -n $VCS_STATUS_TAG && -z $VCS_STATUS_LOCAL_BRANCH ]]
	then
		local tag=${(V)VCS_STATUS_TAG} 
		(( $#tag > 32 )) && tag[13,-13]="…" 
		res+="${meta}#${clean}${tag//\%/%%}" 
	fi
	[[ -z $VCS_STATUS_LOCAL_BRANCH && -z $VCS_STATUS_TAG ]] && res+="${meta}@${clean}${VCS_STATUS_COMMIT[1,8]}" 
	if [[ -n ${VCS_STATUS_REMOTE_BRANCH:#$VCS_STATUS_LOCAL_BRANCH} ]]
	then
		res+="${meta}:${clean}${(V)VCS_STATUS_REMOTE_BRANCH//\%/%%}" 
	fi
	if [[ $VCS_STATUS_COMMIT_SUMMARY == (|*[^[:alnum:]])(wip|WIP)(|[^[:alnum:]]*) ]]
	then
		res+=" ${modified}wip" 
	fi
	(( VCS_STATUS_COMMITS_BEHIND )) && res+=" ${clean}⇣${VCS_STATUS_COMMITS_BEHIND}" 
	(( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )) && res+=" " 
	(( VCS_STATUS_COMMITS_AHEAD  )) && res+="${clean}⇡${VCS_STATUS_COMMITS_AHEAD}" 
	(( VCS_STATUS_PUSH_COMMITS_BEHIND )) && res+=" ${clean}⇠${VCS_STATUS_PUSH_COMMITS_BEHIND}" 
	(( VCS_STATUS_PUSH_COMMITS_AHEAD && !VCS_STATUS_PUSH_COMMITS_BEHIND )) && res+=" " 
	(( VCS_STATUS_PUSH_COMMITS_AHEAD  )) && res+="${clean}⇢${VCS_STATUS_PUSH_COMMITS_AHEAD}" 
	(( VCS_STATUS_STASHES        )) && res+=" ${clean}*${VCS_STATUS_STASHES}" 
	[[ -n $VCS_STATUS_ACTION ]] && res+=" ${conflicted}${VCS_STATUS_ACTION}" 
	(( VCS_STATUS_NUM_CONFLICTED )) && res+=" ${conflicted}~${VCS_STATUS_NUM_CONFLICTED}" 
	(( VCS_STATUS_NUM_STAGED     )) && res+=" ${modified}+${VCS_STATUS_NUM_STAGED}" 
	(( VCS_STATUS_NUM_UNSTAGED   )) && res+=" ${modified}!${VCS_STATUS_NUM_UNSTAGED}" 
	(( VCS_STATUS_NUM_UNTRACKED  )) && res+=" ${untracked}${(g::)POWERLEVEL9K_VCS_UNTRACKED_ICON}${VCS_STATUS_NUM_UNTRACKED}" 
	(( VCS_STATUS_HAS_UNSTAGED == -1 )) && res+=" ${modified}─" 
	typeset -g my_git_format=$res 
}
nccn () {
	cd ~/Documents/guidelines/NCCN
	sh ~/Documents/guidelines/NCCN/nccn.sh
}
neovim_fzf () {
	FILE=$(fzf-pre) 
	if [ -n "$FILE" ]
	then
		nvim +10 "$FILE"
	else
		
	fi
}
netlify_pub () {
	netlify deploy -p --dir=$1
}
newpj () {
	echo -n "Enter project name: "
	read project_name
	echo -n "Enter due month (1-12): "
	read month
	echo -n "Enter due day (1-31): "
	read day
	year=$(date +"%Y") 
	project_name_sanitized=$(echo "$project_name" | tr ' ' '_') 
	folder_path=~/Dropbox/sprint/"$year"-$(printf "%02d" $month)-$(printf "%02d" $day)-"$project_name_sanitized" 
	mkdir -p -p "$folder_path"
	echo "# $project_name" > "$folder_path/README.md"
	cd "$folder_path"
	nvim README.md
}
node () {
	lazyload fnm node npm -- $'_load_fnm' && node "$@"
}
note () {
	cd ~/Dropbox/Medical/
	content=$(pbpaste) 
	title="\n## Note: $(date +"%Y-%m-%d %H:%M")\n" 
	content_with_title="$title$content" 
	filename=$(fzf-pre) 
	echo -e "$content_with_title" >> "$filename"
	nvim $filename
}
notify () {
	local title="$1" 
	local content="$2" 
	osascript -e "display notification \"$content\" with title \"$title\""
}
npm () {
	lazyload fnm node npm -- $'_load_fnm' && npm "$@"
}
nvm_prompt_info () {
	which nvm &> /dev/null || return
	local nvm_prompt=${$(nvm current)#v} 
	echo "${ZSH_THEME_NVM_PROMPT_PREFIX}${nvm_prompt:gs/%/%%}${ZSH_THEME_NVM_PROMPT_SUFFIX}"
}
omz () {
	[[ $# -gt 0 ]] || {
		_omz::help
		return 1
	}
	local command="$1" 
	shift
	(( ${+functions[_omz::$command]} )) || {
		_omz::help
		return 1
	}
	_omz::$command "$@"
}
omz_diagnostic_dump () {
	emulate -L zsh
	builtin echo "Generating diagnostic dump; please be patient..."
	local thisfcn=omz_diagnostic_dump 
	local -A opts
	local opt_verbose opt_noverbose opt_outfile
	local timestamp=$(date +%Y%m%d-%H%M%S) 
	local outfile=omz_diagdump_$timestamp.txt 
	builtin zparseopts -A opts -D -- "v+=opt_verbose" "V+=opt_noverbose"
	local verbose n_verbose=${#opt_verbose} n_noverbose=${#opt_noverbose} 
	(( verbose = 1 + n_verbose - n_noverbose ))
	if [[ ${#*} > 0 ]]
	then
		opt_outfile=$1 
	fi
	if [[ ${#*} > 1 ]]
	then
		builtin echo "$thisfcn: error: too many arguments" >&2
		return 1
	fi
	if [[ -n "$opt_outfile" ]]
	then
		outfile="$opt_outfile" 
	fi
	_omz_diag_dump_one_big_text &> "$outfile"
	if [[ $? != 0 ]]
	then
		builtin echo "$thisfcn: error while creating diagnostic dump; see $outfile for details"
	fi
	builtin echo
	builtin echo Diagnostic dump file created at: "$outfile"
	builtin echo
	builtin echo To share this with OMZ developers, post it as a gist on GitHub
	builtin echo at "https://gist.github.com" and share the link to the gist.
	builtin echo
	builtin echo "WARNING: This dump file contains all your zsh and omz configuration files,"
	builtin echo "so don't share it publicly if there's sensitive information in them."
	builtin echo
}
omz_history () {
	local clear list
	zparseopts -E c=clear l=list
	if [[ -n "$clear" ]]
	then
		echo -n >| "$HISTFILE"
		fc -p "$HISTFILE"
		echo History file deleted. >&2
	elif [[ -n "$list" ]]
	then
		builtin fc "$@"
	else
		[[ ${@[-1]-} = *[0-9]* ]] && builtin fc -l "$@" || builtin fc -l "$@" 1
	fi
}
omz_termsupport_cwd () {
	local URL_HOST URL_PATH
	URL_HOST="$(omz_urlencode -P $HOST)"  || return 1
	URL_PATH="$(omz_urlencode -P $PWD)"  || return 1
	[[ -z "$KONSOLE_VERSION" ]] || URL_HOST="" 
	printf "\e]7;file://%s%s\e\\" "${URL_HOST}" "${URL_PATH}"
}
omz_termsupport_precmd () {
	[[ "${DISABLE_AUTO_TITLE:-}" != true ]] || return
	title "$ZSH_THEME_TERM_TAB_TITLE_IDLE" "$ZSH_THEME_TERM_TITLE_IDLE"
}
omz_termsupport_preexec () {
	[[ "${DISABLE_AUTO_TITLE:-}" != true ]] || return
	emulate -L zsh
	setopt extended_glob
	local -a cmdargs
	cmdargs=("${(z)2}") 
	if [[ "${cmdargs[1]}" = fg ]]
	then
		local job_id jobspec="${cmdargs[2]#%}" 
		case "$jobspec" in
			(<->) job_id=${jobspec}  ;;
			("" | % | +) job_id=${(k)jobstates[(r)*:+:*]}  ;;
			(-) job_id=${(k)jobstates[(r)*:-:*]}  ;;
			([?]*) job_id=${(k)jobtexts[(r)*${(Q)jobspec}*]}  ;;
			(*) job_id=${(k)jobtexts[(r)${(Q)jobspec}*]}  ;;
		esac
		if [[ -n "${jobtexts[$job_id]}" ]]
		then
			1="${jobtexts[$job_id]}" 
			2="${jobtexts[$job_id]}" 
		fi
	fi
	local CMD="${1[(wr)^(*=*|sudo|ssh|mosh|rake|-*)]:gs/%/%%}" 
	local LINE="${2:gs/%/%%}" 
	title "$CMD" "%100>...>${LINE}%<<"
}
omz_urldecode () {
	emulate -L zsh
	local encoded_url=$1 
	local caller_encoding=$langinfo[CODESET] 
	local LC_ALL=C 
	export LC_ALL
	local tmp=${encoded_url:gs/+/ /} 
	tmp=${tmp:gs/\\/\\\\/} 
	tmp=${tmp:gs/%/\\x/} 
	local decoded="$(printf -- "$tmp")" 
	local -a safe_encodings
	safe_encodings=(UTF-8 utf8 US-ASCII) 
	if [[ -z ${safe_encodings[(r)$caller_encoding]} ]]
	then
		decoded=$(echo -E "$decoded" | iconv -f UTF-8 -t $caller_encoding) 
		if [[ $? != 0 ]]
		then
			echo "Error converting string from UTF-8 to $caller_encoding" >&2
			return 1
		fi
	fi
	echo -E "$decoded"
}
omz_urlencode () {
	emulate -L zsh
	local -a opts
	zparseopts -D -E -a opts r m P
	local in_str="$@" 
	local url_str="" 
	local spaces_as_plus
	if [[ -z $opts[(r)-P] ]]
	then
		spaces_as_plus=1 
	fi
	local str="$in_str" 
	local encoding=$langinfo[CODESET] 
	local safe_encodings
	safe_encodings=(UTF-8 utf8 US-ASCII) 
	if [[ -z ${safe_encodings[(r)$encoding]} ]]
	then
		str=$(echo -E "$str" | iconv -f $encoding -t UTF-8) 
		if [[ $? != 0 ]]
		then
			echo "Error converting string from $encoding to UTF-8" >&2
			return 1
		fi
	fi
	local i byte ord LC_ALL=C 
	export LC_ALL
	local reserved=';/?:@&=+$,' 
	local mark='_.!~*''()-' 
	local dont_escape="[A-Za-z0-9" 
	if [[ -z $opts[(r)-r] ]]
	then
		dont_escape+=$reserved 
	fi
	if [[ -z $opts[(r)-m] ]]
	then
		dont_escape+=$mark 
	fi
	dont_escape+="]" 
	local url_str="" 
	for ((i = 1; i <= ${#str}; ++i )) do
		byte="$str[i]" 
		if [[ "$byte" =~ "$dont_escape" ]]
		then
			url_str+="$byte" 
		else
			if [[ "$byte" == " " && -n $spaces_as_plus ]]
			then
				url_str+="+" 
			else
				ord=$(( [##16] #byte )) 
				url_str+="%$ord" 
			fi
		fi
	done
	echo -E "$url_str"
}
open_command () {
	local open_cmd
	case "$OSTYPE" in
		(darwin*) open_cmd='open'  ;;
		(cygwin*) open_cmd='cygstart'  ;;
		(linux*) [[ "$(uname -r)" != *icrosoft* ]] && open_cmd='nohup xdg-open'  || {
				open_cmd='cmd.exe /c start ""' 
				[[ -e "$1" ]] && {
					1="$(wslpath -w "${1:a}")"  || return 1
				}
			} ;;
		(msys*) open_cmd='start ""'  ;;
		(*) echo "Platform $OSTYPE not supported"
			return 1 ;;
	esac
	if [[ -n "$BROWSER" && "$1" = (http|https)://* ]]
	then
		"$BROWSER" "$@"
		return
	fi
	${=open_cmd} "$@" &> /dev/null
}
openai () {
	export OPENAI_API_KEY=$(op read "op://Dev/chat_GPT/api key") 
}
p10k () {
	[[ $# != 1 || $1 != finalize ]] || {
		p10k-instant-prompt-finalize
		return 0
	}
	eval "$__p9k_intro_no_reply"
	if (( !ARGC ))
	then
		print -rP -- $__p9k_p10k_usage >&2
		return 1
	fi
	case $1 in
		(segment) local REPLY
			local -a reply
			shift
			local -i OPTIND
			local OPTARG opt state bg=0 fg icon cond text ref=0 expand=0 
			while getopts ':s:b:f:i:c:t:reh' opt
			do
				case $opt in
					(s) state=$OPTARG  ;;
					(b) bg=$OPTARG  ;;
					(f) fg=$OPTARG  ;;
					(i) icon=$OPTARG  ;;
					(c) cond=${OPTARG:-'${:-}'}  ;;
					(t) text=$OPTARG  ;;
					(r) ref=1  ;;
					(e) expand=1  ;;
					(+r) ref=0  ;;
					(+e) expand=0  ;;
					(h) print -rP -- $__p9k_p10k_segment_usage
						return 0 ;;
					(?) print -rP -- $__p9k_p10k_segment_usage >&2
						return 1 ;;
				esac
			done
			if (( OPTIND <= ARGC ))
			then
				print -rP -- $__p9k_p10k_segment_usage >&2
				return 1
			fi
			if [[ -z $_p9k__prompt_side ]]
			then
				print -rP -- "%1F[ERROR]%f %Bp10k segment%b: can be called only during prompt rendering." >&2
				if (( !ARGC ))
				then
					print -rP -- ""
					print -rP -- "For help, type:" >&2
					print -rP -- ""
					print -rP -- "  %2Fp10k%f %Bhelp%b %Bsegment%b" >&2
				fi
				return 1
			fi
			(( ref )) || icon=$'\1'$icon 
			typeset -i _p9k__has_upglob
			"_p9k_${_p9k__prompt_side}_prompt_segment" "prompt_${_p9k__segment_name}${state:+_${${(U)state}//İ/I}}" "$bg" "${fg:-$_p9k_color1}" "$icon" "$expand" "$cond" "$text"
			return 0 ;;
		(display) if (( ARGC == 1 ))
			then
				print -rP -- $__p9k_p10k_display_usage >&2
				return 1
			fi
			shift
			local -i k dump
			local opt prev new pair list name var
			while getopts ':har' opt
			do
				case $opt in
					(r) if (( __p9k_reset_state > 0 ))
						then
							__p9k_reset_state=2 
						else
							__p9k_reset_state=-1 
						fi ;;
					(a) dump=1  ;;
					(h) print -rP -- $__p9k_p10k_display_usage
						return 0 ;;
					(?) print -rP -- $__p9k_p10k_display_usage >&2
						return 1 ;;
				esac
			done
			if (( dump ))
			then
				reply=() 
				shift $((OPTIND-1))
				(( ARGC )) || set -- '*'
				for opt
				do
					for k in ${(u@)_p9k_display_k[(I)$opt]:/(#m)*/$_p9k_display_k[$MATCH]}
					do
						reply+=($_p9k__display_v[k,k+1]) 
					done
				done
				if (( __p9k_reset_state == -1 ))
				then
					_p9k_reset_prompt
				fi
				return 0
			fi
			local REPLY
			local -a reply
			for opt in "${@:$OPTIND}"
			do
				pair=(${(s:=:)opt}) 
				list=(${(s:,:)${pair[2]}}) 
				if [[ ${(b)pair[1]} == $pair[1] ]]
				then
					local ks=($_p9k_display_k[$pair[1]]) 
				else
					local ks=(${(u@)_p9k_display_k[(I)$pair[1]]:/(#m)*/$_p9k_display_k[$MATCH]}) 
				fi
				for k in $ks
				do
					if (( $#list == 1 ))
					then
						[[ $_p9k__display_v[k+1] == $list[1] ]] && continue
						new=$list[1] 
					else
						new=${list[list[(I)$_p9k__display_v[k+1]]+1]:-$list[1]} 
						[[ $_p9k__display_v[k+1] == $new ]] && continue
					fi
					_p9k__display_v[k+1]=$new 
					name=$_p9k__display_v[k] 
					if [[ $name == (empty_line|ruler) ]]
					then
						var=_p9k__${name}_i 
						[[ $new == show ]] && unset $var || typeset -gi $var=3
					elif [[ $name == (#b)(<->)(*) ]]
					then
						var=_p9k__${match[1]}${${${${match[2]//\/}/#left/l}/#right/r}/#gap/g} 
						[[ $new == hide ]] && typeset -g $var= || unset $var
					fi
					if (( __p9k_reset_state > 0 ))
					then
						__p9k_reset_state=2 
					else
						__p9k_reset_state=-1 
					fi
				done
			done
			if (( __p9k_reset_state == -1 ))
			then
				_p9k_reset_prompt
			fi ;;
		(configure) if (( ARGC > 1 ))
			then
				print -rP -- $__p9k_p10k_configure_usage >&2
				return 1
			fi
			local REPLY
			local -a reply
			p9k_configure "$@" || return ;;
		(reload) if (( ARGC > 1 ))
			then
				print -rP -- $__p9k_p10k_reload_usage >&2
				return 1
			fi
			(( $+_p9k__force_must_init )) || return 0
			_p9k__force_must_init=1  ;;
		(help) local var=__p9k_p10k_$2_usage 
			if (( $+parameters[$var] ))
			then
				print -rP -- ${(P)var}
				return 0
			elif (( ARGC == 1 ))
			then
				print -rP -- $__p9k_p10k_usage
				return 0
			else
				print -rP -- $__p9k_p10k_usage >&2
				return 1
			fi ;;
		(finalize) print -rP -- $__p9k_p10k_finalize_usage >&2
			return 1 ;;
		(clear-instant-prompt) if (( $+__p9k_instant_prompt_active ))
			then
				_p9k_clear_instant_prompt
				unset __p9k_instant_prompt_active
			fi
			return 0 ;;
		(*) print -rP -- $__p9k_p10k_usage >&2
			return 1 ;;
	esac
}
p10k-instant-prompt-finalize () {
	unsetopt local_options
	(( ${+__p9k_instant_prompt_active} )) && unsetopt prompt_cr prompt_sp || setopt prompt_cr prompt_sp
}
p9k_configure () {
	eval "$__p9k_intro"
	_p9k_can_configure || return
	(
		set -- -f
		builtin source $__p9k_root_dir/internal/wizard.zsh
	)
	local ret=$? 
	case $ret in
		(0) builtin source $__p9k_cfg_path
			_p9k__force_must_init=1  ;;
		(69) return 0 ;;
		(*) return $ret ;;
	esac
}
p9k_prompt_segment () {
	p10k segment "$@"
}
parse_git_dirty () {
	local STATUS
	local -a FLAGS
	FLAGS=('--porcelain') 
	if [[ "$(__git_prompt_git config --get oh-my-zsh.hide-dirty)" != "1" ]]
	then
		if [[ "${DISABLE_UNTRACKED_FILES_DIRTY:-}" == "true" ]]
		then
			FLAGS+='--untracked-files=no' 
		fi
		case "${GIT_STATUS_IGNORE_SUBMODULES:-}" in
			(git)  ;;
			(*) FLAGS+="--ignore-submodules=${GIT_STATUS_IGNORE_SUBMODULES:-dirty}"  ;;
		esac
		STATUS=$(__git_prompt_git status ${FLAGS} 2> /dev/null | tail -n 1) 
	fi
	if [[ -n $STATUS ]]
	then
		echo "$ZSH_THEME_GIT_PROMPT_DIRTY"
	else
		echo "$ZSH_THEME_GIT_PROMPT_CLEAN"
	fi
}
patients () {
	cd ~/Dropbox/patients/
	nvim "$(find . -type f -name "*.md" | sed 's|^\./||' | fzf-pre)"
}
pdf () {
	cd ~/Documents/10_PDF檔/
	(
		marp_serve > /dev/null 2>&1 &
	)
	FILE=$(find . \
    -path ./node_modules \
    -prune -o -type f -name "*.pdf" -print |
    sed 's|^\./||' |
    fzf-pre) 
	if [ -n "$FILE" ]
	then
		open "$FILE"
	else
		echo "溫故而知新，可以為師矣"
	fi
}
playlist () {
	playlist_name=$(yt-dlp "$1" -I 1:1 --skip-download --no-warning --print playlist_title | tr ' ' '_' | tr -d '/\\' | tr -d '[:punct:]') 
	echo "start to generate playlist: ${playlist_name}"
	yt-dlp -i --get-filename -o "%(title)s" "$1" > "${playlist_name}.txt"
}
powerlevel10k_plugin_unload () {
	prompt_powerlevel9k_teardown
}
print_icon () {
	eval "$__p9k_intro"
	_p9k_init_icons
	local var=POWERLEVEL9K_$1 
	if (( $+parameters[$var] ))
	then
		echo -n - ${(P)var}
	else
		echo -n - $icons[$1]
	fi
}
prompt__p9k_internal_nothing () {
	_p9k__prompt+='${_p9k__sss::=}' 
}
prompt_anaconda () {
	local msg
	if _p9k_python_version
	then
		P9K_ANACONDA_PYTHON_VERSION=$_p9k__ret 
		if (( _POWERLEVEL9K_ANACONDA_SHOW_PYTHON_VERSION ))
		then
			msg="${P9K_ANACONDA_PYTHON_VERSION//\%/%%} " 
		fi
	else
		unset P9K_ANACONDA_PYTHON_VERSION
	fi
	local p=${CONDA_PREFIX:-$CONDA_ENV_PATH} 
	msg+="$_POWERLEVEL9K_ANACONDA_LEFT_DELIMITER${${p:t}//\%/%%}$_POWERLEVEL9K_ANACONDA_RIGHT_DELIMITER" 
	_p9k_prompt_segment "$0" "blue" "$_p9k_color1" 'PYTHON_ICON' 0 '' "$msg"
}
prompt_asdf () {
	_p9k_asdf_check_meta || _p9k_asdf_init_meta || return
	local -A versions
	local -a stat
	local -i has_global
	local dirs=($_p9k__parent_dirs) 
	local mtimes=($_p9k__parent_mtimes) 
	if [[ $dirs[-1] != ~ ]]
	then
		zstat -A stat +mtime ~ 2> /dev/null || return
		dirs+=(~) 
		mtimes+=($stat[1]) 
	fi
	local elem
	for elem in ${(@)${:-{1..$#dirs}}/(#m)*/${${:-$MATCH:$_p9k__asdf_dir2files[$dirs[MATCH]]}#$MATCH:$mtimes[MATCH]:}}
	do
		if [[ $elem == *:* ]]
		then
			local dir=$dirs[${elem%%:*}] 
			zstat -A stat +mtime $dir 2> /dev/null || return
			local files=($dir/.tool-versions(N) $dir/${(k)^_p9k_asdf_file_info}(N)) 
			_p9k__asdf_dir2files[$dir]=$stat[1]:${(pj:\0:)files} 
		else
			local files=(${(0)elem}) 
		fi
		if [[ ${files[1]:h} == ~ ]]
		then
			has_global=1 
			local -A local_versions=(${(kv)versions}) 
			versions=() 
		fi
		local file
		for file in $files
		do
			[[ $file == */.tool-versions ]]
			_p9k_asdf_parse_version_file $file $? || return
		done
	done
	if (( ! has_global ))
	then
		has_global=1 
		local -A local_versions=(${(kv)versions}) 
		versions=() 
	fi
	if [[ -r $ASDF_DEFAULT_TOOL_VERSIONS_FILENAME ]]
	then
		_p9k_asdf_parse_version_file $ASDF_DEFAULT_TOOL_VERSIONS_FILENAME 0 || return
	fi
	local plugin
	for plugin in ${(k)_p9k_asdf_plugins}
	do
		local upper=${${(U)plugin//-/_}//İ/I} 
		if (( $+parameters[_POWERLEVEL9K_ASDF_${upper}_SOURCES] ))
		then
			local sources=(${(P)${:-_POWERLEVEL9K_ASDF_${upper}_SOURCES}}) 
		else
			local sources=($_POWERLEVEL9K_ASDF_SOURCES) 
		fi
		local version="${(P)${:-ASDF_${upper}_VERSION}}" 
		if [[ -n $version ]]
		then
			(( $sources[(I)shell] )) || continue
		else
			version=$local_versions[$plugin] 
			if [[ -n $version ]]
			then
				(( $sources[(I)local] )) || continue
			else
				version=$versions[$plugin] 
				[[ -n $version ]] || continue
				(( $sources[(I)global] )) || continue
			fi
		fi
		if [[ $version == $versions[$plugin] ]]
		then
			if (( $+parameters[_POWERLEVEL9K_ASDF_${upper}_PROMPT_ALWAYS_SHOW] ))
			then
				(( _POWERLEVEL9K_ASDF_${upper}_PROMPT_ALWAYS_SHOW )) || continue
			else
				(( _POWERLEVEL9K_ASDF_PROMPT_ALWAYS_SHOW )) || continue
			fi
		fi
		if [[ $version == system ]]
		then
			if (( $+parameters[_POWERLEVEL9K_ASDF_${upper}_SHOW_SYSTEM] ))
			then
				(( _POWERLEVEL9K_ASDF_${upper}_SHOW_SYSTEM )) || continue
			else
				(( _POWERLEVEL9K_ASDF_SHOW_SYSTEM )) || continue
			fi
		fi
		_p9k_get_icon $0_$upper ${upper}_ICON $plugin
		_p9k_prompt_segment $0_$upper green $_p9k_color1 $'\1'$_p9k__ret 0 '' ${version//\%/%%}
	done
}
prompt_aws () {
	typeset -g P9K_AWS_PROFILE="${AWS_VAULT:-${AWSUME_PROFILE:-${AWS_PROFILE:-$AWS_DEFAULT_PROFILE}}}" 
	local pat class state
	for pat class in "${_POWERLEVEL9K_AWS_CLASSES[@]}"
	do
		if [[ $P9K_AWS_PROFILE == ${~pat} ]]
		then
			[[ -n $class ]] && state=_${${(U)class}//İ/I} 
			break
		fi
	done
	if [[ -n ${AWS_REGION:-$AWS_DEFAULT_REGION} ]]
	then
		typeset -g P9K_AWS_REGION=${AWS_REGION:-$AWS_DEFAULT_REGION} 
	else
		local cfg=${AWS_CONFIG_FILE:-~/.aws/config} 
		if ! _p9k_cache_stat_get $0 $cfg
		then
			local -a reply
			_p9k_parse_aws_config $cfg
			_p9k_cache_stat_set $reply
		fi
		local prefix=$#P9K_AWS_PROFILE:$P9K_AWS_PROFILE: 
		local kv=$_p9k__cache_val[(r)${(b)prefix}*] 
		typeset -g P9K_AWS_REGION=${kv#$prefix} 
	fi
	_p9k_prompt_segment "$0$state" red white 'AWS_ICON' 0 '' "${P9K_AWS_PROFILE//\%/%%}"
}
prompt_aws_eb_env () {
	_p9k_upglob .elasticbeanstalk && return
	local dir=$_p9k__parent_dirs[$?] 
	if ! _p9k_cache_stat_get $0 $dir/.elasticbeanstalk/config.yml
	then
		local env
		env="$(command eb list 2>/dev/null)"  || env= 
		env="${${(@M)${(@f)env}:#\* *}#\* }" 
		_p9k_cache_stat_set "$env"
	fi
	[[ -n $_p9k__cache_val[1] ]] || return
	_p9k_prompt_segment "$0" black green 'AWS_EB_ICON' 0 '' "${_p9k__cache_val[1]//\%/%%}"
}
prompt_azure () {
	local cfg=${AZURE_CONFIG_DIR:-$HOME/.azure}/azureProfile.json 
	if ! _p9k_cache_stat_get $0 $cfg
	then
		local name
		if (( $+commands[jq] )) && name="$(jq -r '[.subscriptions[]|select(.isDefault==true)|.name][]|strings' $cfg 2>/dev/null)" 
		then
			name=${name%%$'\n'*} 
		elif ! name="$(az account show --query name --output tsv 2>/dev/null)" 
		then
			name= 
		fi
		_p9k_cache_stat_set "$name"
	fi
	local pat class state
	for pat class in "${_POWERLEVEL9K_AZURE_CLASSES[@]}"
	do
		if [[ $name == ${~pat} ]]
		then
			[[ -n $class ]] && state=_${${(U)class}//İ/I} 
			break
		fi
	done
	[[ -n $_p9k__cache_val[1] ]] || return
	_p9k_prompt_segment "$0$state" "blue" "white" "AZURE_ICON" 0 '' "${_p9k__cache_val[1]//\%/%%}"
}
prompt_background_jobs () {
	local -i len=$#_p9k__prompt _p9k__has_upglob 
	local msg
	if (( _POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE ))
	then
		if (( _POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE_ALWAYS ))
		then
			msg='${(%):-%j}' 
		else
			msg='${${(%):-%j}:#1}' 
		fi
	fi
	_p9k_prompt_segment $0 "$_p9k_color1" cyan BACKGROUND_JOBS_ICON 1 '${${(%):-%j}:#0}' "$msg"
	(( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}
prompt_battery () {
	[[ $_p9k_os == (Linux|Android) ]] && _p9k_prompt_battery_set_args
	(( $#_p9k__battery_args )) && _p9k_prompt_segment "${_p9k__battery_args[@]}"
}
prompt_chruby () {
	local v
	(( _POWERLEVEL9K_CHRUBY_SHOW_ENGINE )) && v=$RUBY_ENGINE 
	if [[ $_POWERLEVEL9K_CHRUBY_SHOW_VERSION == 1 && -n $RUBY_VERSION ]] && v+=${v:+ }$RUBY_VERSION 
		_p9k_prompt_segment "$0" "red" "$_p9k_color1" 'RUBY_ICON' 0 '' "${v//\%/%%}"
	then
		
	fi
}
prompt_command_execution_time () {
	(( $+P9K_COMMAND_DURATION_SECONDS )) || return
	(( P9K_COMMAND_DURATION_SECONDS >= _POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD )) || return
	if (( P9K_COMMAND_DURATION_SECONDS < 60 ))
	then
		if (( !_POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION ))
		then
			local -i sec=$((P9K_COMMAND_DURATION_SECONDS + 0.5)) 
		else
			local -F $_POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION sec=P9K_COMMAND_DURATION_SECONDS 
		fi
		local text=${sec}s 
	else
		local -i d=$((P9K_COMMAND_DURATION_SECONDS + 0.5)) 
		if [[ $_POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT == "H:M:S" ]]
		then
			local text=${(l.2..0.)$((d % 60))} 
			if (( d >= 60 ))
			then
				text=${(l.2..0.)$((d / 60 % 60))}:$text 
				if (( d >= 36000 ))
				then
					text=$((d / 3600)):$text 
				elif (( d >= 3600 ))
				then
					text=0$((d / 3600)):$text 
				fi
			fi
		else
			local text="$((d % 60))s" 
			if (( d >= 60 ))
			then
				text="$((d / 60 % 60))m $text" 
				if (( d >= 3600 ))
				then
					text="$((d / 3600 % 24))h $text" 
					if (( d >= 86400 ))
					then
						text="$((d / 86400))d $text" 
					fi
				fi
			fi
		fi
	fi
	_p9k_prompt_segment "$0" "red" "yellow1" 'EXECUTION_TIME_ICON' 0 '' $text
}
prompt_context () {
	local -i len=$#_p9k__prompt _p9k__has_upglob 
	local content
	if [[ $_POWERLEVEL9K_ALWAYS_SHOW_CONTEXT == 0 && -n $DEFAULT_USER && $P9K_SSH == 0 ]]
	then
		local user="${(%):-%n}" 
		if [[ $user == $DEFAULT_USER ]]
		then
			content="${user//\%/%%}" 
		fi
	fi
	local state
	if (( P9K_SSH ))
	then
		if [[ -n "$SUDO_COMMAND" ]]
		then
			state="REMOTE_SUDO" 
		else
			state="REMOTE" 
		fi
	elif [[ -n "$SUDO_COMMAND" ]]
	then
		state="SUDO" 
	else
		state="DEFAULT" 
	fi
	local cond
	for state cond in $state '${${(%):-%#}:#\#}' ROOT '${${(%):-%#}:#\%}'
	do
		local text=$content 
		if [[ -z $text ]]
		then
			local var=_POWERLEVEL9K_CONTEXT_${state}_TEMPLATE 
			if (( $+parameters[$var] ))
			then
				text=${(P)var} 
				text=${(g::)text} 
			else
				text=$_POWERLEVEL9K_CONTEXT_TEMPLATE 
			fi
		fi
		_p9k_prompt_segment "$0_$state" "$_p9k_color1" yellow '' 0 "$cond" "$text"
	done
	(( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}
prompt_date () {
	if [[ $_p9k__refresh_reason == precmd ]]
	then
		if [[ $+__p9k_instant_prompt_active == 1 && $__p9k_instant_prompt_date_format == $_POWERLEVEL9K_DATE_FORMAT ]]
		then
			_p9k__date=${__p9k_instant_prompt_date//\%/%%} 
		else
			_p9k__date=${${(%)_POWERLEVEL9K_DATE_FORMAT}//\%/%%} 
		fi
	fi
	_p9k_prompt_segment "$0" "$_p9k_color2" "$_p9k_color1" "DATE_ICON" 0 '' "$_p9k__date"
}
prompt_detect_virt () {
	local virt="$(systemd-detect-virt 2>/dev/null)" 
	if [[ "$virt" == "none" ]]
	then
		local -a inode
		if zstat -A inode +inode / 2> /dev/null && [[ $inode[1] != 2 ]]
		then
			virt="chroot" 
		fi
	fi
	if [[ -n "${virt}" ]]
	then
		_p9k_prompt_segment "$0" "$_p9k_color1" "yellow" '' 0 '' "${virt//\%/%%}"
	fi
}
prompt_dir () {
	if (( _POWERLEVEL9K_DIR_PATH_ABSOLUTE ))
	then
		local p=${(V)_p9k__cwd} 
		local -a parts=("${(s:/:)p}") 
	elif [[ -o auto_name_dirs ]]
	then
		local p=${(V)${_p9k__cwd/#(#b)$HOME(|\/*)/'~'$match[1]}} 
		local -a parts=("${(s:/:)p}") 
	else
		local p=${(%):-%~} 
		if [[ $p == '~['* ]]
		then
			local func='' 
			local -a parts=() 
			for func in zsh_directory_name $zsh_directory_name_functions
			do
				local reply=() 
				if (( $+functions[$func] )) && $func d $_p9k__cwd && [[ $p == '~['${(V)reply[1]}']'* ]]
				then
					parts+='~['${(V)reply[1]}']' 
					break
				fi
			done
			if (( $#parts ))
			then
				parts+=(${(s:/:)${p#$parts[1]}}) 
			else
				p=${(V)_p9k__cwd} 
				parts=("${(s:/:)p}") 
			fi
		else
			local -a parts=("${(s:/:)p}") 
		fi
	fi
	local -i fake_first=0 expand=0 shortenlen=${_POWERLEVEL9K_SHORTEN_DIR_LENGTH:--1} 
	if (( $+_POWERLEVEL9K_SHORTEN_DELIMITER ))
	then
		local delim=$_POWERLEVEL9K_SHORTEN_DELIMITER 
	else
		if [[ $langinfo[CODESET] == (utf|UTF)(-|)8 ]]
		then
			local delim=$'\u2026' 
		else
			local delim='..' 
		fi
	fi
	case $_POWERLEVEL9K_SHORTEN_STRATEGY in
		(truncate_absolute | truncate_absolute_chars) if (( shortenlen > 0 && $#p > shortenlen ))
			then
				_p9k_shorten_delim_len $delim
				if (( $#p > shortenlen + $_p9k__ret ))
				then
					local -i n=shortenlen 
					local -i i=$#parts 
					while true
					do
						local dir=$parts[i] 
						local -i len=$(( $#dir + (i > 1) )) 
						if (( len <= n ))
						then
							(( n -= len ))
							(( --i ))
						else
							parts[i]=$'\1'$dir[-n,-1] 
							parts[1,i-1]=() 
							break
						fi
					done
				fi
			fi ;;
		(truncate_with_package_name | truncate_middle | truncate_from_right) () {
				[[ $_POWERLEVEL9K_SHORTEN_STRATEGY == truncate_with_package_name && $+commands[jq] == 1 && $#_POWERLEVEL9K_DIR_PACKAGE_FILES > 0 ]] || return
				local pats="(${(j:|:)_POWERLEVEL9K_DIR_PACKAGE_FILES})" 
				local -i i=$#parts 
				local dir=$_p9k__cwd 
				for ((; i > 0; --i )) do
					local markers=($dir/${~pats}(N)) 
					if (( $#markers ))
					then
						local pat= pkg_file= 
						for pat in $_POWERLEVEL9K_DIR_PACKAGE_FILES
						do
							for pkg_file in $markers
							do
								[[ $pkg_file == $dir/${~pat} ]] || continue
								if ! _p9k_cache_stat_get $0_pkg $pkg_file
								then
									local pkg_name='' 
									pkg_name="$(jq -j '.name | select(. != null)' <$pkg_file 2>/dev/null)"  || pkg_name='' 
									_p9k_cache_stat_set "$pkg_name"
								fi
								[[ -n $_p9k__cache_val[1] ]] || continue
								parts[1,i]=($_p9k__cache_val[1]) 
								fake_first=1 
								return 0
							done
						done
					fi
					dir=${dir:h} 
				done
			}
			if (( shortenlen > 0 ))
			then
				_p9k_shorten_delim_len $delim
				local -i d=_p9k__ret pref=shortenlen suf=0 i=2 
				[[ $_POWERLEVEL9K_SHORTEN_STRATEGY == truncate_middle ]] && suf=pref 
				for ((; i < $#parts; ++i )) do
					local dir=$parts[i] 
					if (( $#dir > pref + suf + d ))
					then
						dir[pref+1,-suf-1]=$'\1' 
						parts[i]=$dir 
					fi
				done
			fi ;;
		(truncate_to_last) shortenlen=${_POWERLEVEL9K_SHORTEN_DIR_LENGTH:-1} 
			(( shortenlen > 0 )) || shortenlen=1 
			local -i i='shortenlen+1' 
			if [[ $#parts -gt i || ( $p[1] != / && $#parts -gt shortenlen ) ]]
			then
				fake_first=1 
				parts[1,-i]=() 
			fi ;;
		(truncate_to_first_and_last) if (( shortenlen > 0 ))
			then
				local -i i=$(( shortenlen + 1 )) 
				[[ $p == /* ]] && (( ++i ))
				for ((; i <= $#parts - shortenlen; ++i )) do
					parts[i]=$'\1' 
				done
			fi ;;
		(truncate_to_unique) expand=1 
			delim=${_POWERLEVEL9K_SHORTEN_DELIMITER-'*'} 
			shortenlen=${_POWERLEVEL9K_SHORTEN_DIR_LENGTH:-1} 
			(( shortenlen >= 0 )) || shortenlen=1 
			local rp=${(g:oce:)p} 
			local rparts=("${(@s:/:)rp}") 
			local -i i=2 e=$(($#parts - shortenlen)) 
			if [[ -n $_POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER ]]
			then
				(( e += shortenlen ))
				local orig=("$parts[2]" "${(@)parts[$((shortenlen > $#parts ? -$#parts : -shortenlen)),-1]}") 
			elif [[ $p[1] == / ]]
			then
				(( ++i ))
			fi
			if (( i <= e ))
			then
				local mtimes=(${(Oa)_p9k__parent_mtimes:$(($#parts-e)):$((e-i+1))}) 
				local key="${(pj.:.)mtimes}" 
			else
				local key= 
			fi
			if ! _p9k_cache_ephemeral_get $0 $e $i $_p9k__cwd || [[ $key != $_p9k__cache_val[1] ]]
			then
				local rtail=${(j./.)rparts[i,-1]} 
				local parent=$_p9k__cwd[1,-2-$#rtail] 
				_p9k_prompt_length $delim
				local -i real_delim_len=_p9k__ret 
				[[ -n $parts[i-1] ]] && parts[i-1]="\${(Q)\${:-${(qqq)${(q)parts[i-1]}}}}"$'\2' 
				local -i d=${_POWERLEVEL9K_SHORTEN_DELIMITER_LENGTH:--1} 
				(( d >= 0 )) || d=real_delim_len 
				local -i m=1 
				for ((; i <= e; ++i, ++m )) do
					local sub=$parts[i] 
					local rsub=$rparts[i] 
					local dir=$parent/$rsub mtime=$mtimes[m] 
					local pair=$_p9k__dir_stat_cache[$dir] 
					if [[ $pair == ${mtime:-x}:* ]]
					then
						parts[i]=${pair#*:} 
					else
						[[ $sub != *["~!#\`\$^&*()\\\"'<>?{}[]"]* ]]
						local -i q=$? 
						if [[ -n $_POWERLEVEL9K_SHORTEN_FOLDER_MARKER && -n $dir/${~_POWERLEVEL9K_SHORTEN_FOLDER_MARKER}(#qN) ]]
						then
							(( q )) && parts[i]="\${(Q)\${:-${(qqq)${(q)sub}}}}" 
							parts[i]+=$'\2' 
						else
							local -i j=$rsub[(i)[^.]] 
							for ((; j + d < $#rsub; ++j )) do
								local -a matching=($parent/$rsub[1,j]*/(N)) 
								(( $#matching == 1 )) && break
							done
							local -i saved=$((${(m)#${(V)${rsub:$j}}} - d)) 
							if (( saved > 0 ))
							then
								if (( q ))
								then
									parts[i]='${${${_p9k__d:#-*}:+${(Q)${:-'${(qqq)${(q)sub}}'}}}:-${(Q)${:-' 
									parts[i]+=$'\3'${(qqq)${(q)${(V)${rsub[1,j]}}}}$'}}\1\3''${$((_p9k__d+='$saved'))+}}' 
								else
									parts[i]='${${${_p9k__d:#-*}:+'$sub$'}:-\3'${(V)${rsub[1,j]}}$'\1\3''${$((_p9k__d+='$saved'))+}}' 
								fi
							else
								(( q )) && parts[i]="\${(Q)\${:-${(qqq)${(q)sub}}}}" 
							fi
						fi
						[[ -n $mtime ]] && _p9k__dir_stat_cache[$dir]="$mtime:$parts[i]" 
					fi
					parent+=/$rsub 
				done
				if [[ -n $_POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER ]]
				then
					local _2=$'\2' 
					if [[ $_POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER == last* ]]
					then
						(( e = ${parts[(I)*$_2]} + ${_POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER#*:} ))
					else
						(( e = ${parts[(ib:2:)*$_2]} + ${_POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER#*:} ))
					fi
					if (( e > 1 && e <= $#parts ))
					then
						parts[1,e-1]=() 
						fake_first=1 
					elif [[ $p == /?* ]]
					then
						parts[2]="\${(Q)\${:-${(qqq)${(q)orig[1]}}}}"$'\2' 
					fi
					for ((i = $#parts < shortenlen ? $#parts : shortenlen; i > 0; --i)) do
						[[ $#parts[-i] == *$'\2' ]] && continue
						if [[ $orig[-i] == *["~!#\`\$^&*()\\\"'<>?{}[]"]* ]]
						then
							parts[-i]='${(Q)${:-'${(qqq)${(q)orig[-i]}}'}}'$'\2' 
						else
							parts[-i]=${orig[-i]}$'\2' 
						fi
					done
				else
					for ((; i <= $#parts; ++i)) do
						[[ $parts[i] == *["~!#\`\$^&*()\\\"'<>?{}[]"]* ]] && parts[i]='${(Q)${:-'${(qqq)${(q)parts[i]}}'}}' 
						parts[i]+=$'\2' 
					done
				fi
				_p9k_cache_ephemeral_set "$key" "${parts[@]}"
			fi
			parts=("${(@)_p9k__cache_val[2,-1]}")  ;;
		(truncate_with_folder_marker) if [[ -n $_POWERLEVEL9K_SHORTEN_FOLDER_MARKER ]]
			then
				local dir=$_p9k__cwd 
				local -a m=() 
				local -i i=$(($#parts - 1)) 
				for ((; i > 1; --i )) do
					dir=${dir:h} 
					[[ -n $dir/${~_POWERLEVEL9K_SHORTEN_FOLDER_MARKER}(#qN) ]] && m+=$i 
				done
				m+=1 
				for ((i=1; i < $#m; ++i )) do
					(( m[i] - m[i+1] > 2 )) && parts[m[i+1]+1,m[i]-1]=($'\1') 
				done
			fi ;;
		(*) if (( shortenlen > 0 ))
			then
				local -i len=$#parts 
				[[ -z $parts[1] ]] && (( --len ))
				if (( len > shortenlen ))
				then
					parts[1,-shortenlen-1]=($'\1') 
				fi
			fi ;;
	esac
	(( !_POWERLEVEL9K_DIR_SHOW_WRITABLE )) || [[ -w $_p9k__cwd ]]
	local -i w=$? 
	(( w && _POWERLEVEL9K_DIR_SHOW_WRITABLE > 2 )) && [[ ! -e $_p9k__cwd ]] && w=2 
	if ! _p9k_cache_ephemeral_get $0 $_p9k__cwd $p $w $fake_first "${parts[@]}"
	then
		local state=$0 
		local icon='' 
		local a='' b='' c='' 
		for a b c in "${_POWERLEVEL9K_DIR_CLASSES[@]}"
		do
			if [[ $_p9k__cwd == ${~a} ]]
			then
				[[ -n $b ]] && state+=_${${(U)b}//İ/I} 
				icon=$'\1'$c 
				break
			fi
		done
		if (( w ))
		then
			if (( _POWERLEVEL9K_DIR_SHOW_WRITABLE == 1 ))
			then
				state=${0}_NOT_WRITABLE 
			elif (( w == 2 ))
			then
				state+=_NON_EXISTENT 
			else
				state+=_NOT_WRITABLE 
			fi
			icon=LOCK_ICON 
		fi
		local state_u=${${(U)state}//İ/I} 
		local style=%b 
		_p9k_color $state BACKGROUND blue
		_p9k_background $_p9k__ret
		style+=$_p9k__ret 
		_p9k_color $state FOREGROUND "$_p9k_color1"
		_p9k_foreground $_p9k__ret
		style+=$_p9k__ret 
		if (( expand ))
		then
			_p9k_escape_style $style
			style=$_p9k__ret 
		fi
		parts=("${(@)parts//\%/%%}") 
		if [[ $_POWERLEVEL9K_HOME_FOLDER_ABBREVIATION != '~' && $fake_first == 0 && $p == ('~'|'~/'*) ]]
		then
			(( expand )) && _p9k_escape $_POWERLEVEL9K_HOME_FOLDER_ABBREVIATION || _p9k__ret=$_POWERLEVEL9K_HOME_FOLDER_ABBREVIATION 
			parts[1]=$_p9k__ret 
			[[ $_p9k__ret == *%* ]] && parts[1]+=$style 
		elif [[ $_POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER == 1 && $fake_first == 0 && $#parts > 1 && -z $parts[1] && -n $parts[2] ]]
		then
			parts[1]=() 
		fi
		local last_style= 
		_p9k_param $state PATH_HIGHLIGHT_BOLD ''
		[[ $_p9k__ret == true ]] && last_style+=%B 
		if (( $+parameters[_POWERLEVEL9K_DIR_PATH_HIGHLIGHT_FOREGROUND] ||
          $+parameters[_POWERLEVEL9K_${state_u}_PATH_HIGHLIGHT_FOREGROUND] ))
		then
			_p9k_color $state PATH_HIGHLIGHT_FOREGROUND ''
			_p9k_foreground $_p9k__ret
			last_style+=$_p9k__ret 
		fi
		if [[ -n $last_style ]]
		then
			(( expand )) && _p9k_escape_style $last_style || _p9k__ret=$last_style 
			parts[-1]=$_p9k__ret${parts[-1]//$'\1'/$'\1'$_p9k__ret}$style 
		fi
		local anchor_style= 
		_p9k_param $state ANCHOR_BOLD ''
		[[ $_p9k__ret == true ]] && anchor_style+=%B 
		if (( $+parameters[_POWERLEVEL9K_DIR_ANCHOR_FOREGROUND] ||
          $+parameters[_POWERLEVEL9K_${state_u}_ANCHOR_FOREGROUND] ))
		then
			_p9k_color $state ANCHOR_FOREGROUND ''
			_p9k_foreground $_p9k__ret
			anchor_style+=$_p9k__ret 
		fi
		if [[ -n $anchor_style ]]
		then
			(( expand )) && _p9k_escape_style $anchor_style || _p9k__ret=$anchor_style 
			if [[ -z $last_style ]]
			then
				parts=("${(@)parts/%(#b)(*)$'\2'/$_p9k__ret$match[1]$style}") 
			else
				(( $#parts > 1 )) && parts[1,-2]=("${(@)parts[1,-2]/%(#b)(*)$'\2'/$_p9k__ret$match[1]$style}") 
				parts[-1]=${parts[-1]/$'\2'} 
			fi
		else
			parts=("${(@)parts/$'\2'}") 
		fi
		if (( $+parameters[_POWERLEVEL9K_DIR_SHORTENED_FOREGROUND] ||
          $+parameters[_POWERLEVEL9K_${state_u}_SHORTENED_FOREGROUND] ))
		then
			_p9k_color $state SHORTENED_FOREGROUND ''
			_p9k_foreground $_p9k__ret
			(( expand )) && _p9k_escape_style $_p9k__ret
			local shortened_fg=$_p9k__ret 
			(( expand )) && _p9k_escape $delim || _p9k__ret=$delim 
			[[ $_p9k__ret == *%* ]] && _p9k__ret+=$style$shortened_fg 
			parts=("${(@)parts/(#b)$'\3'(*)$'\1'(*)$'\3'/$shortened_fg$match[1]$_p9k__ret$match[2]$style}") 
			parts=("${(@)parts/(#b)(*)$'\1'(*)/$shortened_fg$match[1]$_p9k__ret$match[2]$style}") 
		else
			(( expand )) && _p9k_escape $delim || _p9k__ret=$delim 
			[[ $_p9k__ret == *%* ]] && _p9k__ret+=$style 
			parts=("${(@)parts/$'\1'/$_p9k__ret}") 
			parts=("${(@)parts//$'\3'}") 
		fi
		if [[ $_p9k__cwd == / && $_POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER == 1 ]]
		then
			local sep='/' 
		else
			local sep='' 
			if (( $+parameters[_POWERLEVEL9K_DIR_PATH_SEPARATOR_FOREGROUND] ||
            $+parameters[_POWERLEVEL9K_${state_u}_PATH_SEPARATOR_FOREGROUND] ))
			then
				_p9k_color $state PATH_SEPARATOR_FOREGROUND ''
				_p9k_foreground $_p9k__ret
				(( expand )) && _p9k_escape_style $_p9k__ret
				sep=$_p9k__ret 
			fi
			_p9k_param $state PATH_SEPARATOR /
			_p9k__ret=${(g::)_p9k__ret} 
			(( expand )) && _p9k_escape $_p9k__ret
			sep+=$_p9k__ret 
			[[ $sep == *%* ]] && sep+=$style 
		fi
		local content="${(pj.$sep.)parts}" 
		if (( _POWERLEVEL9K_DIR_HYPERLINK && _p9k_term_has_href )) && [[ $_p9k__cwd == /* ]]
		then
			_p9k_url_escape $_p9k__cwd
			local header=$'%{\e]8;;file://'$_p9k__ret$'\a%}' 
			local footer=$'%{\e]8;;\a%}' 
			if (( expand ))
			then
				_p9k_escape $header
				header=$_p9k__ret 
				_p9k_escape $footer
				footer=$_p9k__ret 
			fi
			content=$header$content$footer 
		fi
		(( expand )) && _p9k_prompt_length "${(e):-"\${\${_p9k__d::=0}+}$content"}" || _p9k__ret= 
		_p9k_cache_ephemeral_set "$state" "$icon" "$expand" "$content" $_p9k__ret
	fi
	if (( _p9k__cache_val[3] ))
	then
		if (( $+_p9k__dir ))
		then
			_p9k__cache_val[4]='${${_p9k__d::=-1024}+}'$_p9k__cache_val[4] 
		else
			_p9k__dir=$_p9k__cache_val[4] 
			_p9k__dir_len=$_p9k__cache_val[5] 
			_p9k__cache_val[4]='%{d%}'$_p9k__cache_val[4]'%{d%}' 
		fi
	fi
	_p9k_prompt_segment "$_p9k__cache_val[1]" "blue" "$_p9k_color1" "$_p9k__cache_val[2]" "$_p9k__cache_val[3]" "" "$_p9k__cache_val[4]"
}
prompt_dir_writable () {
	if [[ ! -w "$_p9k__cwd_a" ]]
	then
		_p9k_prompt_segment "$0_FORBIDDEN" "red" "yellow1" 'LOCK_ICON' 0 '' ''
	fi
}
prompt_direnv () {
	local -i len=$#_p9k__prompt _p9k__has_upglob 
	_p9k_prompt_segment $0 $_p9k_color1 yellow DIRENV_ICON 0 '${DIRENV_DIR-}' ''
	(( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}
prompt_disk_usage () {
	local -i len=$#_p9k__prompt _p9k__has_upglob 
	_p9k_prompt_segment $0_CRITICAL red white DISK_ICON 1 '$_p9k__disk_usage_critical' '$_p9k__disk_usage_pct%%'
	_p9k_prompt_segment $0_WARNING yellow $_p9k_color1 DISK_ICON 1 '$_p9k__disk_usage_warning' '$_p9k__disk_usage_pct%%'
	if (( ! _POWERLEVEL9K_DISK_USAGE_ONLY_WARNING ))
	then
		_p9k_prompt_segment $0_NORMAL $_p9k_color1 yellow DISK_ICON 1 '$_p9k__disk_usage_normal' '$_p9k__disk_usage_pct%%'
	fi
	(( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}
prompt_docker_machine () {
	_p9k_prompt_segment "$0" "magenta" "$_p9k_color1" 'SERVER_ICON' 0 '' "${DOCKER_MACHINE_NAME//\%/%%}"
}
prompt_dotnet_version () {
	if (( _POWERLEVEL9K_DOTNET_VERSION_PROJECT_ONLY ))
	then
		_p9k_upglob 'project.json|global.json|packet.dependencies|*.csproj|*.fsproj|*.xproj|*.sln' && return
	fi
	_p9k_cached_cmd 0 '' dotnet --version || return
	_p9k_prompt_segment "$0" "magenta" "white" 'DOTNET_ICON' 0 '' "$_p9k__ret"
}
prompt_dropbox () {
	local dropbox_status="$(dropbox-cli filestatus . | cut -d\  -f2-)" 
	if [[ "$dropbox_status" != 'unwatched' && "$dropbox_status" != "isn't running!" ]]
	then
		if [[ "$dropbox_status" =~ 'up to date' ]]
		then
			dropbox_status="" 
		fi
		_p9k_prompt_segment "$0" "white" "blue" "DROPBOX_ICON" 0 '' "${dropbox_status//\%/%%}"
	fi
}
prompt_example () {
	p10k segment -f 208 -i '⭐' -t 'hello, %n'
}
prompt_fvm () {
	_p9k_fvm_new || _p9k_fvm_old
}
prompt_gcloud () {
	local -i len=$#_p9k__prompt _p9k__has_upglob 
	_p9k_prompt_segment $0_PARTIAL blue white GCLOUD_ICON 1 '${${(M)${#P9K_GCLOUD_PROJECT_NAME}:#0}:+$P9K_GCLOUD_ACCOUNT$P9K_GCLOUD_PROJECT_ID}' '${P9K_GCLOUD_ACCOUNT//\%/%%}:${P9K_GCLOUD_PROJECT_ID//\%/%%}'
	_p9k_prompt_segment $0_COMPLETE blue white GCLOUD_ICON 1 '$P9K_GCLOUD_PROJECT_NAME' '${P9K_GCLOUD_ACCOUNT//\%/%%}:${P9K_GCLOUD_PROJECT_ID//\%/%%}'
	(( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}
prompt_go_version () {
	_p9k_cached_cmd 0 '' go version || return
	[[ $_p9k__ret == (#b)*go([[:digit:].]##)* ]] || return
	local v=$match[1] 
	if (( _POWERLEVEL9K_GO_VERSION_PROJECT_ONLY ))
	then
		local p=$GOPATH 
		if [[ -z $p ]]
		then
			if [[ -d $HOME/go ]]
			then
				p=$HOME/go 
			else
				p="$(go env GOPATH 2>/dev/null)"  && [[ -n $p ]] || return
			fi
		fi
		if [[ $_p9k__cwd/ != $p/* && $_p9k__cwd_a/ != $p/* ]]
		then
			_p9k_upglob go.mod && return
		fi
	fi
	_p9k_prompt_segment "$0" "green" "grey93" "GO_ICON" 0 '' "${v//\%/%%}"
}
prompt_goenv () {
	local v=${(j.:.)${(@)${(s.:.)GOENV_VERSION}#go-}} 
	if [[ -n $v ]]
	then
		(( ${_POWERLEVEL9K_GOENV_SOURCES[(I)shell]} )) || return
	else
		(( ${_POWERLEVEL9K_GOENV_SOURCES[(I)local|global]} )) || return
		_p9k__ret= 
		if [[ $GOENV_DIR != (|.) ]]
		then
			[[ $GOENV_DIR == /* ]] && local dir=$GOENV_DIR  || local dir="$_p9k__cwd_a/$GOENV_DIR" 
			dir=${dir:A} 
			if [[ $dir != $_p9k__cwd_a ]]
			then
				while true
				do
					if _p9k_read_pyenv_like_version_file $dir/.go-version go-
					then
						(( ${_POWERLEVEL9K_GOENV_SOURCES[(I)local]} )) || return
						break
					fi
					[[ $dir == (/|.) ]] && break
					dir=${dir:h} 
				done
			fi
		fi
		if [[ -z $_p9k__ret ]]
		then
			_p9k_upglob .go-version
			local -i idx=$? 
			if (( idx )) && _p9k_read_pyenv_like_version_file $_p9k__parent_dirs[idx]/.go-version go-
			then
				(( ${_POWERLEVEL9K_GOENV_SOURCES[(I)local]} )) || return
			else
				_p9k__ret= 
			fi
		fi
		if [[ -z $_p9k__ret ]]
		then
			(( _POWERLEVEL9K_GOENV_PROMPT_ALWAYS_SHOW )) || return
			(( ${_POWERLEVEL9K_GOENV_SOURCES[(I)global]} )) || return
			_p9k_goenv_global_version
		fi
		v=$_p9k__ret 
	fi
	if (( !_POWERLEVEL9K_GOENV_PROMPT_ALWAYS_SHOW ))
	then
		_p9k_goenv_global_version
		[[ $v == $_p9k__ret ]] && return
	fi
	if (( !_POWERLEVEL9K_GOENV_SHOW_SYSTEM ))
	then
		[[ $v == system ]] && return
	fi
	_p9k_prompt_segment "$0" "blue" "$_p9k_color1" 'GO_ICON' 0 '' "${v//\%/%%}"
}
prompt_google_app_cred () {
	unset P9K_GOOGLE_APP_CRED_{TYPE,PROJECT_ID,CLIENT_EMAIL}
	if ! _p9k_cache_stat_get $0 $GOOGLE_APPLICATION_CREDENTIALS
	then
		local -a lines
		local q='[.type//"", .project_id//"", .client_email//"", 0][]' 
		if lines=("${(@f)$(jq -r $q <$GOOGLE_APPLICATION_CREDENTIALS 2>/dev/null)}")  && (( $#lines == 4 ))
		then
			local text="${(j.:.)lines[1,-2]}" 
			local pat class state
			for pat class in "${_POWERLEVEL9K_GOOGLE_APP_CRED_CLASSES[@]}"
			do
				if [[ $text == ${~pat} ]]
				then
					[[ -n $class ]] && state=_${${(U)class}//İ/I} 
					break
				fi
			done
			_p9k_cache_stat_set 1 "${(@)lines[1,-2]}" "$text" "$state"
		else
			_p9k_cache_stat_set 0
		fi
	fi
	(( _p9k__cache_val[1] )) || return
	P9K_GOOGLE_APP_CRED_TYPE=$_p9k__cache_val[2] 
	P9K_GOOGLE_APP_CRED_PROJECT_ID=$_p9k__cache_val[3] 
	P9K_GOOGLE_APP_CRED_CLIENT_EMAIL=$_p9k__cache_val[4] 
	_p9k_prompt_segment "$0$_p9k__cache_val[6]" "blue" "white" "GCLOUD_ICON" 0 '' "$_p9k__cache_val[5]"
}
prompt_haskell_stack () {
	if [[ -n $STACK_YAML ]]
	then
		(( ${_POWERLEVEL9K_HASKELL_STACK_SOURCES[(I)shell]} )) || return
		_p9k_haskell_stack_version $STACK_YAML
	else
		(( ${_POWERLEVEL9K_HASKELL_STACK_SOURCES[(I)local|global]} )) || return
		if _p9k_upglob stack.yaml
		then
			(( _POWERLEVEL9K_HASKELL_STACK_PROMPT_ALWAYS_SHOW )) || return
			(( ${_POWERLEVEL9K_HASKELL_STACK_SOURCES[(I)global]} )) || return
			_p9k_haskell_stack_version ${STACK_ROOT:-~/.stack}/global-project/stack.yaml
		else
			local -i idx=$? 
			(( ${_POWERLEVEL9K_HASKELL_STACK_SOURCES[(I)local]} )) || return
			_p9k_haskell_stack_version $_p9k__parent_dirs[idx]/stack.yaml
		fi
	fi
	[[ -n $_p9k__ret ]] || return
	local v=$_p9k__ret 
	if (( !_POWERLEVEL9K_HASKELL_STACK_PROMPT_ALWAYS_SHOW ))
	then
		_p9k_haskell_stack_version ${STACK_ROOT:-~/.stack}/global-project/stack.yaml
		[[ $v == $_p9k__ret ]] && return
	fi
	_p9k_prompt_segment "$0" "yellow" "$_p9k_color1" 'HASKELL_ICON' 0 '' "${v//\%/%%}"
}
prompt_history () {
	local -i len=$#_p9k__prompt _p9k__has_upglob 
	_p9k_prompt_segment "$0" "grey50" "$_p9k_color1" '' 0 '' '%h'
	(( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}
prompt_host () {
	local -i len=$#_p9k__prompt _p9k__has_upglob 
	if (( P9K_SSH ))
	then
		_p9k_prompt_segment "$0_REMOTE" "${_p9k_color1}" yellow SSH_ICON 0 '' "$_POWERLEVEL9K_HOST_TEMPLATE"
	else
		_p9k_prompt_segment "$0_LOCAL" "${_p9k_color1}" yellow HOST_ICON 0 '' "$_POWERLEVEL9K_HOST_TEMPLATE"
	fi
	(( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}
prompt_ip () {
	local -i len=$#_p9k__prompt _p9k__has_upglob 
	_p9k_prompt_segment "$0" "cyan" "$_p9k_color1" 'NETWORK_ICON' 1 '$P9K_IP_IP' '$P9K_IP_IP'
	(( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}
prompt_java_version () {
	if (( _POWERLEVEL9K_JAVA_VERSION_PROJECT_ONLY ))
	then
		_p9k_upglob 'pom.xml|build.gradle.kts|build.sbt|deps.edn|project.clj|build.boot|*.(java|class|jar|gradle|clj|cljc)' && return
	fi
	local java=$commands[java] 
	if ! _p9k_cache_stat_get $0 $java ${JAVA_HOME:+$JAVA_HOME/release}
	then
		local v
		v="$(java -fullversion 2>&1)"  || v= 
		v=${${v#*\"}%\"*} 
		(( _POWERLEVEL9K_JAVA_VERSION_FULL )) || v=${v%%-*} 
		_p9k_cache_stat_set "${v//\%/%%}"
	fi
	[[ -n $_p9k__cache_val[1] ]] || return
	_p9k_prompt_segment "$0" "red" "white" "JAVA_ICON" 0 '' $_p9k__cache_val[1]
}
prompt_jenv () {
	if [[ -n $JENV_VERSION ]]
	then
		(( ${_POWERLEVEL9K_JENV_SOURCES[(I)shell]} )) || return
		local v=$JENV_VERSION 
	else
		(( ${_POWERLEVEL9K_JENV_SOURCES[(I)local|global]} )) || return
		_p9k__ret= 
		if [[ $JENV_DIR != (|.) ]]
		then
			[[ $JENV_DIR == /* ]] && local dir=$JENV_DIR  || local dir="$_p9k__cwd_a/$JENV_DIR" 
			dir=${dir:A} 
			if [[ $dir != $_p9k__cwd_a ]]
			then
				while true
				do
					if _p9k_read_word $dir/.java-version
					then
						(( ${_POWERLEVEL9K_JENV_SOURCES[(I)local]} )) || return
						break
					fi
					[[ $dir == (/|.) ]] && break
					dir=${dir:h} 
				done
			fi
		fi
		if [[ -z $_p9k__ret ]]
		then
			_p9k_upglob .java-version
			local -i idx=$? 
			if (( idx )) && _p9k_read_word $_p9k__parent_dirs[idx]/.java-version
			then
				(( ${_POWERLEVEL9K_JENV_SOURCES[(I)local]} )) || return
			else
				_p9k__ret= 
			fi
		fi
		if [[ -z $_p9k__ret ]]
		then
			(( _POWERLEVEL9K_JENV_PROMPT_ALWAYS_SHOW )) || return
			(( ${_POWERLEVEL9K_JENV_SOURCES[(I)global]} )) || return
			_p9k_jenv_global_version
		fi
		local v=$_p9k__ret 
	fi
	if (( !_POWERLEVEL9K_JENV_PROMPT_ALWAYS_SHOW ))
	then
		_p9k_jenv_global_version
		[[ $v == $_p9k__ret ]] && return
	fi
	if (( !_POWERLEVEL9K_JENV_SHOW_SYSTEM ))
	then
		[[ $v == system ]] && return
	fi
	_p9k_prompt_segment "$0" white red 'JAVA_ICON' 0 '' "${v//\%/%%}"
}
prompt_kubecontext () {
	if ! _p9k_cache_stat_get $0 ${(s.:.)${KUBECONFIG:-$HOME/.kube/config}}
	then
		local name namespace cluster user cloud_name cloud_account cloud_zone cloud_cluster text state
		() {
			local cfg && cfg=(${(f)"$(kubectl config view -o=yaml 2>/dev/null)"})  || return
			local qstr='"*"' 
			local str='([^"'\''|>]*|'$qstr')' 
			local ctx=(${(@M)cfg:#current-context: $~str}) 
			(( $#ctx == 1 )) || return
			name=${ctx[1]#current-context: } 
			local -i pos=${cfg[(i)contexts:]} 
			{
				(( pos <= $#cfg )) || return
				shift $pos cfg
				pos=${cfg[(i)  name: ${(b)name}]} 
				(( pos <= $#cfg )) || return
				(( --pos ))
				for ((; pos > 0; --pos)) do
					local line=$cfg[pos] 
					if [[ $line == '- context:' ]]
					then
						return 0
					elif [[ $line == (#b)'    cluster: '($~str) ]]
					then
						cluster=$match[1] 
						[[ $cluster == $~qstr ]] && cluster=$cluster[2,-2] 
					elif [[ $line == (#b)'    namespace: '($~str) ]]
					then
						namespace=$match[1] 
						[[ $namespace == $~qstr ]] && namespace=$namespace[2,-2] 
					elif [[ $line == (#b)'    user: '($~str) ]]
					then
						user=$match[1] 
						[[ $user == $~qstr ]] && user=$user[2,-2] 
					fi
				done
			} always {
				[[ $name == $~qstr ]] && name=$name[2,-2] 
			}
		}
		if [[ -n $name ]]
		then
			: ${namespace:=default}
			if [[ $cluster == (#b)gke_(?*)_(asia|australia|europe|northamerica|southamerica|us)-([a-z]##<->)(-[a-z]|)_(?*) ]]
			then
				cloud_name=gke 
				cloud_account=$match[1] 
				cloud_zone=$match[2]-$match[3]$match[4] 
				cloud_cluster=$match[5] 
				if (( ${_POWERLEVEL9K_KUBECONTEXT_SHORTEN[(I)gke]} ))
				then
					text=$cloud_cluster 
				fi
			elif [[ $cluster == (#b)arn:aws:eks:([[:alnum:]-]##):([[:digit:]]##):cluster/(?*) ]]
			then
				cloud_name=eks 
				cloud_zone=$match[1] 
				cloud_account=$match[2] 
				cloud_cluster=$match[3] 
				if (( ${_POWERLEVEL9K_KUBECONTEXT_SHORTEN[(I)eks]} ))
				then
					text=$cloud_cluster 
				fi
			fi
			if [[ -z $text ]]
			then
				text=$name 
				if [[ $_POWERLEVEL9K_KUBECONTEXT_SHOW_DEFAULT_NAMESPACE == 1 || $namespace != (default|$name) ]]
				then
					text+="/$namespace" 
				fi
			fi
			local pat class
			for pat class in "${_POWERLEVEL9K_KUBECONTEXT_CLASSES[@]}"
			do
				if [[ $text == ${~pat} ]]
				then
					[[ -n $class ]] && state=_${${(U)class}//İ/I} 
					break
				fi
			done
		fi
		_p9k_cache_stat_set "${(g::)name}" "${(g::)namespace}" "${(g::)cluster}" "${(g::)user}" "${(g::)cloud_name}" "${(g::)cloud_account}" "${(g::)cloud_zone}" "${(g::)cloud_cluster}" "${(g::)text}" "$state"
	fi
	typeset -g P9K_KUBECONTEXT_NAME=$_p9k__cache_val[1] 
	typeset -g P9K_KUBECONTEXT_NAMESPACE=$_p9k__cache_val[2] 
	typeset -g P9K_KUBECONTEXT_CLUSTER=$_p9k__cache_val[3] 
	typeset -g P9K_KUBECONTEXT_USER=$_p9k__cache_val[4] 
	typeset -g P9K_KUBECONTEXT_CLOUD_NAME=$_p9k__cache_val[5] 
	typeset -g P9K_KUBECONTEXT_CLOUD_ACCOUNT=$_p9k__cache_val[6] 
	typeset -g P9K_KUBECONTEXT_CLOUD_ZONE=$_p9k__cache_val[7] 
	typeset -g P9K_KUBECONTEXT_CLOUD_CLUSTER=$_p9k__cache_val[8] 
	[[ -n $_p9k__cache_val[9] ]] || return
	_p9k_prompt_segment $0$_p9k__cache_val[10] magenta white KUBERNETES_ICON 0 '' "${_p9k__cache_val[9]//\%/%%}"
}
prompt_laravel_version () {
	_p9k_upglob artisan && return
	local dir=$_p9k__parent_dirs[$?] 
	local app=$dir/vendor/laravel/framework/src/Illuminate/Foundation/Application.php 
	[[ -r $app ]] || return
	if ! _p9k_cache_stat_get $0 $dir/artisan $app
	then
		local v="$(php $dir/artisan --version 2> /dev/null)" 
		_p9k_cache_stat_set "${${(M)v:#Laravel Framework *}#Laravel Framework }"
	fi
	[[ -n $_p9k__cache_val[1] ]] || return
	_p9k_prompt_segment "$0" "maroon" "white" 'LARAVEL_ICON' 0 '' "${_p9k__cache_val[1]//\%/%%}"
}
prompt_load () {
	if [[ $_p9k_os == (OSX|BSD) ]]
	then
		local -i len=$#_p9k__prompt _p9k__has_upglob 
		_p9k_prompt_segment $0_CRITICAL red "$_p9k_color1" LOAD_ICON 1 '$_p9k__load_critical' '$_p9k__load_value'
		_p9k_prompt_segment $0_WARNING yellow "$_p9k_color1" LOAD_ICON 1 '$_p9k__load_warning' '$_p9k__load_value'
		_p9k_prompt_segment $0_NORMAL green "$_p9k_color1" LOAD_ICON 1 '$_p9k__load_normal' '$_p9k__load_value'
		(( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
		return
	fi
	[[ -r /proc/loadavg ]] || return
	_p9k_read_file /proc/loadavg || return
	local load=${${(A)=_p9k__ret}[_POWERLEVEL9K_LOAD_WHICH]//,/.} 
	local -F pct='100. * load / _p9k_num_cpus' 
	if (( pct > _POWERLEVEL9K_LOAD_CRITICAL_PCT ))
	then
		_p9k_prompt_segment $0_CRITICAL red "$_p9k_color1" LOAD_ICON 0 '' $load
	elif (( pct > _POWERLEVEL9K_LOAD_WARNING_PCT ))
	then
		_p9k_prompt_segment $0_WARNING yellow "$_p9k_color1" LOAD_ICON 0 '' $load
	else
		_p9k_prompt_segment $0_NORMAL green "$_p9k_color1" LOAD_ICON 0 '' $load
	fi
}
prompt_luaenv () {
	if [[ -n $LUAENV_VERSION ]]
	then
		(( ${_POWERLEVEL9K_LUAENV_SOURCES[(I)shell]} )) || return
		local v=$LUAENV_VERSION 
	else
		(( ${_POWERLEVEL9K_LUAENV_SOURCES[(I)local|global]} )) || return
		_p9k__ret= 
		if [[ $LUAENV_DIR != (|.) ]]
		then
			[[ $LUAENV_DIR == /* ]] && local dir=$LUAENV_DIR  || local dir="$_p9k__cwd_a/$LUAENV_DIR" 
			dir=${dir:A} 
			if [[ $dir != $_p9k__cwd_a ]]
			then
				while true
				do
					if _p9k_read_word $dir/.lua-version
					then
						(( ${_POWERLEVEL9K_LUAENV_SOURCES[(I)local]} )) || return
						break
					fi
					[[ $dir == (/|.) ]] && break
					dir=${dir:h} 
				done
			fi
		fi
		if [[ -z $_p9k__ret ]]
		then
			_p9k_upglob .lua-version
			local -i idx=$? 
			if (( idx )) && _p9k_read_word $_p9k__parent_dirs[idx]/.lua-version
			then
				(( ${_POWERLEVEL9K_LUAENV_SOURCES[(I)local]} )) || return
			else
				_p9k__ret= 
			fi
		fi
		if [[ -z $_p9k__ret ]]
		then
			(( _POWERLEVEL9K_LUAENV_PROMPT_ALWAYS_SHOW )) || return
			(( ${_POWERLEVEL9K_LUAENV_SOURCES[(I)global]} )) || return
			_p9k_luaenv_global_version
		fi
		local v=$_p9k__ret 
	fi
	if (( !_POWERLEVEL9K_LUAENV_PROMPT_ALWAYS_SHOW ))
	then
		_p9k_luaenv_global_version
		[[ $v == $_p9k__ret ]] && return
	fi
	if (( !_POWERLEVEL9K_LUAENV_SHOW_SYSTEM ))
	then
		[[ $v == system ]] && return
	fi
	_p9k_prompt_segment "$0" blue "$_p9k_color1" 'LUA_ICON' 0 '' "${v//\%/%%}"
}
prompt_midnight_commander () {
	local -i len=$#_p9k__prompt _p9k__has_upglob 
	_p9k_prompt_segment $0 $_p9k_color1 yellow MIDNIGHT_COMMANDER_ICON 0 '' ''
	(( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}
prompt_nix_shell () {
	_p9k_prompt_segment $0 4 $_p9k_color1 NIX_SHELL_ICON 0 '' "${(M)IN_NIX_SHELL:#(pure|impure)}"
}
prompt_nnn () {
	_p9k_prompt_segment $0 6 $_p9k_color1 NNN_ICON 0 '' $NNNLVL
}
prompt_node_version () {
	_p9k_upglob package.json
	local -i idx=$? 
	if (( idx ))
	then
		_p9k_cached_cmd 0 $_p9k__parent_dirs[idx]/package.json node --version || return
	else
		(( _POWERLEVEL9K_NODE_VERSION_PROJECT_ONLY )) && return
		_p9k_cached_cmd 0 '' node --version || return
	fi
	[[ $_p9k__ret == v?* ]] || return
	_p9k_prompt_segment "$0" "green" "white" 'NODE_ICON' 0 '' "${_p9k__ret#v}"
}
prompt_nodeenv () {
	local msg
	if (( _POWERLEVEL9K_NODEENV_SHOW_NODE_VERSION )) && _p9k_cached_cmd 0 '' node --version
	then
		msg="${_p9k__ret//\%/%%} " 
	fi
	msg+="$_POWERLEVEL9K_NODEENV_LEFT_DELIMITER${${NODE_VIRTUAL_ENV:t}//\%/%%}$_POWERLEVEL9K_NODEENV_RIGHT_DELIMITER" 
	_p9k_prompt_segment "$0" "black" "green" 'NODE_ICON' 0 '' "$msg"
}
prompt_nodenv () {
	if [[ -n $NODENV_VERSION ]]
	then
		(( ${_POWERLEVEL9K_NODENV_SOURCES[(I)shell]} )) || return
		local v=$NODENV_VERSION 
	else
		(( ${_POWERLEVEL9K_NODENV_SOURCES[(I)local|global]} )) || return
		_p9k__ret= 
		if [[ $NODENV_DIR != (|.) ]]
		then
			[[ $NODENV_DIR == /* ]] && local dir=$NODENV_DIR  || local dir="$_p9k__cwd_a/$NODENV_DIR" 
			dir=${dir:A} 
			if [[ $dir != $_p9k__cwd_a ]]
			then
				while true
				do
					if _p9k_read_word $dir/.node-version
					then
						(( ${_POWERLEVEL9K_NODENV_SOURCES[(I)local]} )) || return
						break
					fi
					[[ $dir == (/|.) ]] && break
					dir=${dir:h} 
				done
			fi
		fi
		if [[ -z $_p9k__ret ]]
		then
			_p9k_upglob .node-version
			local -i idx=$? 
			if (( idx )) && _p9k_read_word $_p9k__parent_dirs[idx]/.node-version
			then
				(( ${_POWERLEVEL9K_NODENV_SOURCES[(I)local]} )) || return
			else
				_p9k__ret= 
			fi
		fi
		if [[ -z $_p9k__ret ]]
		then
			(( _POWERLEVEL9K_NODENV_PROMPT_ALWAYS_SHOW )) || return
			(( ${_POWERLEVEL9K_NODENV_SOURCES[(I)global]} )) || return
			_p9k_nodenv_global_version
		fi
		_p9k_nodeenv_version_transform $_p9k__ret || return
		local v=$_p9k__ret 
	fi
	if (( !_POWERLEVEL9K_NODENV_PROMPT_ALWAYS_SHOW ))
	then
		_p9k_nodenv_global_version
		_p9k_nodeenv_version_transform $_p9k__ret && [[ $v == $_p9k__ret ]] && return
	fi
	if (( !_POWERLEVEL9K_NODENV_SHOW_SYSTEM ))
	then
		[[ $v == system ]] && return
	fi
	_p9k_prompt_segment "$0" "black" "green" 'NODE_ICON' 0 '' "${v//\%/%%}"
}
prompt_nordvpn () {
	unset $__p9k_nordvpn_tag P9K_NORDVPN_COUNTRY_CODE
	[[ -e /run/nordvpn/nordvpnd.sock ]] || return
	_p9k_fetch_nordvpn_status 2> /dev/null || return
	if [[ $P9K_NORDVPN_SERVER == (#b)([[:alpha:]]##)[[:digit:]]##.nordvpn.com ]]
	then
		typeset -g P9K_NORDVPN_COUNTRY_CODE=${${(U)match[1]}//İ/I} 
	fi
	case $P9K_NORDVPN_STATUS in
		(Connected) _p9k_prompt_segment $0_CONNECTED blue white NORDVPN_ICON 0 '' "$P9K_NORDVPN_COUNTRY_CODE" ;;
		(Disconnected | Connecting | Disconnecting) local state=${${(U)P9K_NORDVPN_STATUS}//İ/I} 
			_p9k_get_icon $0_$state FAIL_ICON
			_p9k_prompt_segment $0_$state yellow white NORDVPN_ICON 0 '' "$_p9k__ret" ;;
		(*) return ;;
	esac
}
prompt_nvm () {
	[[ -n $NVM_DIR ]] && _p9k_nvm_ls_current || return
	local current=$_p9k__ret 
	! _p9k_nvm_ls_default || [[ $_p9k__ret != $current ]] || return
	_p9k_prompt_segment "$0" "magenta" "black" 'NODE_ICON' 0 '' "${${current#v}//\%/%%}"
}
prompt_openfoam () {
	if [[ -z "$WM_FORK" ]]
	then
		_p9k_prompt_segment "$0" "yellow" "$_p9k_color1" '' 0 '' "OF: ${${WM_PROJECT_VERSION:t}//\%/%%}"
	else
		_p9k_prompt_segment "$0" "yellow" "$_p9k_color1" '' 0 '' "F-X: ${${WM_PROJECT_VERSION:t}//\%/%%}"
	fi
}
prompt_os_icon () {
	local -i len=$#_p9k__prompt _p9k__has_upglob 
	_p9k_prompt_segment "$0" "black" "white" '' 0 '' "$_p9k_os_icon"
	(( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}
prompt_package () {
	unset P9K_PACKAGE_NAME P9K_PACKAGE_VERSION
	_p9k_upglob package.json && return
	local file=$_p9k__parent_dirs[$?]/package.json 
	if ! _p9k_cache_stat_get $0 $file
	then
		() {
			local data field
			local -A found
			{
				data="$(<$file)"  || return
			} 2> /dev/null
			data=${${data//$'\r'}##[[:space:]]#} 
			[[ $data == '{'* ]] || return
			data[1]= 
			local -i depth=1 
			while true
			do
				data=${data##[[:space:]]#} 
				[[ -n $data ]] || return
				case $data[1] in
					('{' | '[') data[1]= 
						(( ++depth )) ;;
					('}' | ']') data[1]= 
						(( --depth > 0 )) || return ;;
					(':') data[1]=  ;;
					(',') data[1]= 
						field=  ;;
					([[:alnum:].]) data=${data##[[:alnum:].]#}  ;;
					('"') local tail=${data##\"([^\"\\]|\\?)#} 
						[[ $tail == '"'* ]] || return
						local s=${data:1:-$#tail} 
						data=${tail:1} 
						(( depth == 1 )) || continue
						if [[ -z $field ]]
						then
							field=${s:-x} 
						elif [[ $field == (name|version) ]]
						then
							(( ! $+found[$field] )) || return
							[[ -n $s ]] || return
							[[ $s != *($'\n'|'\')* ]] || return
							found[$field]=$s 
							(( $#found == 2 )) && break
						fi ;;
					(*) return 1 ;;
				esac
			done
			_p9k_cache_stat_set 1 $found[name] $found[version]
			return 0
		} || _p9k_cache_stat_set 0
	fi
	(( _p9k__cache_val[1] )) || return
	P9K_PACKAGE_NAME=$_p9k__cache_val[2] 
	P9K_PACKAGE_VERSION=$_p9k__cache_val[3] 
	_p9k_prompt_segment "$0" "cyan" "$_p9k_color1" PACKAGE_ICON 0 '' ${P9K_PACKAGE_VERSION//\%/%%}
}
prompt_perlbrew () {
	if (( _POWERLEVEL9K_PERLBREW_PROJECT_ONLY ))
	then
		_p9k_upglob 'cpanfile|.perltidyrc|(|MY)META.(yml|json)|(Makefile|Build).PL|*.(pl|pm|t|pod)' && return
	fi
	local v=$PERLBREW_PERL 
	(( _POWERLEVEL9K_PERLBREW_SHOW_PREFIX )) || v=${v#*-} 
	[[ -n $v ]] || return
	_p9k_prompt_segment "$0" "blue" "$_p9k_color1" 'PERL_ICON' 0 '' "${v//\%/%%}"
}
prompt_php_version () {
	if (( _POWERLEVEL9K_PHP_VERSION_PROJECT_ONLY ))
	then
		_p9k_upglob 'composer.json|*.php' && return
	fi
	_p9k_cached_cmd 0 '' php --version || return
	[[ $_p9k__ret == (#b)(*$'\n')#'PHP '([[:digit:].]##)* ]] || return
	local v=$match[2] 
	_p9k_prompt_segment "$0" "fuchsia" "grey93" 'PHP_ICON' 0 '' "${v//\%/%%}"
}
prompt_phpenv () {
	if [[ -n $PHPENV_VERSION ]]
	then
		(( ${_POWERLEVEL9K_PHPENV_SOURCES[(I)shell]} )) || return
		local v=$PHPENV_VERSION 
	else
		(( ${_POWERLEVEL9K_PHPENV_SOURCES[(I)local|global]} )) || return
		_p9k__ret= 
		if [[ $PHPENV_DIR != (|.) ]]
		then
			[[ $PHPENV_DIR == /* ]] && local dir=$PHPENV_DIR  || local dir="$_p9k__cwd_a/$PHPENV_DIR" 
			dir=${dir:A} 
			if [[ $dir != $_p9k__cwd_a ]]
			then
				while true
				do
					if _p9k_read_word $dir/.php-version
					then
						(( ${_POWERLEVEL9K_PHPENV_SOURCES[(I)local]} )) || return
						break
					fi
					[[ $dir == (/|.) ]] && break
					dir=${dir:h} 
				done
			fi
		fi
		if [[ -z $_p9k__ret ]]
		then
			_p9k_upglob .php-version
			local -i idx=$? 
			if (( idx )) && _p9k_read_word $_p9k__parent_dirs[idx]/.php-version
			then
				(( ${_POWERLEVEL9K_PHPENV_SOURCES[(I)local]} )) || return
			else
				_p9k__ret= 
			fi
		fi
		if [[ -z $_p9k__ret ]]
		then
			(( _POWERLEVEL9K_PHPENV_PROMPT_ALWAYS_SHOW )) || return
			(( ${_POWERLEVEL9K_PHPENV_SOURCES[(I)global]} )) || return
			_p9k_phpenv_global_version
		fi
		local v=$_p9k__ret 
	fi
	if (( !_POWERLEVEL9K_PHPENV_PROMPT_ALWAYS_SHOW ))
	then
		_p9k_phpenv_global_version
		[[ $v == $_p9k__ret ]] && return
	fi
	if (( !_POWERLEVEL9K_PHPENV_SHOW_SYSTEM ))
	then
		[[ $v == system ]] && return
	fi
	_p9k_prompt_segment "$0" "magenta" "$_p9k_color1" 'PHP_ICON' 0 '' "${v//\%/%%}"
}
prompt_plenv () {
	if [[ -n $PLENV_VERSION ]]
	then
		(( ${_POWERLEVEL9K_PLENV_SOURCES[(I)shell]} )) || return
		local v=$PLENV_VERSION 
	else
		(( ${_POWERLEVEL9K_PLENV_SOURCES[(I)local|global]} )) || return
		_p9k__ret= 
		if [[ $PLENV_DIR != (|.) ]]
		then
			[[ $PLENV_DIR == /* ]] && local dir=$PLENV_DIR  || local dir="$_p9k__cwd_a/$PLENV_DIR" 
			dir=${dir:A} 
			if [[ $dir != $_p9k__cwd_a ]]
			then
				while true
				do
					if _p9k_read_word $dir/.perl-version
					then
						(( ${_POWERLEVEL9K_PLENV_SOURCES[(I)local]} )) || return
						break
					fi
					[[ $dir == (/|.) ]] && break
					dir=${dir:h} 
				done
			fi
		fi
		if [[ -z $_p9k__ret ]]
		then
			_p9k_upglob .perl-version
			local -i idx=$? 
			if (( idx )) && _p9k_read_word $_p9k__parent_dirs[idx]/.perl-version
			then
				(( ${_POWERLEVEL9K_PLENV_SOURCES[(I)local]} )) || return
			else
				_p9k__ret= 
			fi
		fi
		if [[ -z $_p9k__ret ]]
		then
			(( _POWERLEVEL9K_PLENV_PROMPT_ALWAYS_SHOW )) || return
			(( ${_POWERLEVEL9K_PLENV_SOURCES[(I)global]} )) || return
			_p9k_plenv_global_version
		fi
		local v=$_p9k__ret 
	fi
	if (( !_POWERLEVEL9K_PLENV_PROMPT_ALWAYS_SHOW ))
	then
		_p9k_plenv_global_version
		[[ $v == $_p9k__ret ]] && return
	fi
	if (( !_POWERLEVEL9K_PLENV_SHOW_SYSTEM ))
	then
		[[ $v == system ]] && return
	fi
	_p9k_prompt_segment "$0" "blue" "$_p9k_color1" 'PERL_ICON' 0 '' "${v//\%/%%}"
}
prompt_powerlevel9k_setup () {
	_p9k_restore_special_params
	eval "$__p9k_intro"
	_p9k_setup
}
prompt_powerlevel9k_teardown () {
	_p9k_restore_special_params
	eval "$__p9k_intro"
	add-zsh-hook -D precmd '(_p9k_|powerlevel9k_)*'
	add-zsh-hook -D preexec '(_p9k_|powerlevel9k_)*'
	PROMPT='%m%# ' 
	RPROMPT= 
	if (( __p9k_enabled ))
	then
		_p9k_deinit
		__p9k_enabled=0 
	fi
}
prompt_prompt_char () {
	local saved=$_p9k__prompt_char_saved[$_p9k__prompt_side$_p9k__segment_index$((!_p9k__status))] 
	if [[ -n $saved ]]
	then
		_p9k__prompt+=$saved 
		return
	fi
	local -i len=$#_p9k__prompt _p9k__has_upglob 
	if (( __p9k_sh_glob ))
	then
		if (( _p9k__status ))
		then
			if (( _POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE ))
			then
				_p9k_prompt_segment $0_ERROR_VIINS "$_p9k_color1" 196 '' 0 '${${${${${${:-$_p9k__keymap.$_p9k__zle_state}:#vicmd.*}:#vivis.*}:#vivli.*}:#*.*overwrite*}}' '❯'
				_p9k_prompt_segment $0_ERROR_VIOWR "$_p9k_color1" 196 '' 0 '${${${${${${:-$_p9k__keymap.$_p9k__zle_state}:#vicmd.*}:#vivis.*}:#vivli.*}:#*.*insert*}}' '▶'
			else
				_p9k_prompt_segment $0_ERROR_VIINS "$_p9k_color1" 196 '' 0 '${${${${_p9k__keymap:#vicmd}:#vivis}:#vivli}}' '❯'
			fi
			_p9k_prompt_segment $0_ERROR_VICMD "$_p9k_color1" 196 '' 0 '${(M)${:-$_p9k__keymap$_p9k__region_active}:#vicmd0}' '❮'
			_p9k_prompt_segment $0_ERROR_VIVIS "$_p9k_color1" 196 '' 0 '${$((! ${#${${${${:-$_p9k__keymap$_p9k__region_active}:#vicmd1}:#vivis?}:#vivli?}})):#0}' 'Ⅴ'
		else
			if (( _POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE ))
			then
				_p9k_prompt_segment $0_OK_VIINS "$_p9k_color1" 76 '' 0 '${${${${${${:-$_p9k__keymap.$_p9k__zle_state}:#vicmd.*}:#vivis.*}:#vivli.*}:#*.*overwrite*}}' '❯'
				_p9k_prompt_segment $0_OK_VIOWR "$_p9k_color1" 76 '' 0 '${${${${${${:-$_p9k__keymap.$_p9k__zle_state}:#vicmd.*}:#vivis.*}:#vivli.*}:#*.*insert*}}' '▶'
			else
				_p9k_prompt_segment $0_OK_VIINS "$_p9k_color1" 76 '' 0 '${${${${_p9k__keymap:#vicmd}:#vivis}:#vivli}}' '❯'
			fi
			_p9k_prompt_segment $0_OK_VICMD "$_p9k_color1" 76 '' 0 '${(M)${:-$_p9k__keymap$_p9k__region_active}:#vicmd0}' '❮'
			_p9k_prompt_segment $0_OK_VIVIS "$_p9k_color1" 76 '' 0 '${$((! ${#${${${${:-$_p9k__keymap$_p9k__region_active}:#vicmd1}:#vivis?}:#vivli?}})):#0}' 'Ⅴ'
		fi
	else
		if (( _p9k__status ))
		then
			if (( _POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE ))
			then
				_p9k_prompt_segment $0_ERROR_VIINS "$_p9k_color1" 196 '' 0 '${${:-$_p9k__keymap.$_p9k__zle_state}:#(vicmd.*|vivis.*|vivli.*|*.*overwrite*)}' '❯'
				_p9k_prompt_segment $0_ERROR_VIOWR "$_p9k_color1" 196 '' 0 '${${:-$_p9k__keymap.$_p9k__zle_state}:#(vicmd.*|vivis.*|vivli.*|*.*insert*)}' '▶'
			else
				_p9k_prompt_segment $0_ERROR_VIINS "$_p9k_color1" 196 '' 0 '${_p9k__keymap:#(vicmd|vivis|vivli)}' '❯'
			fi
			_p9k_prompt_segment $0_ERROR_VICMD "$_p9k_color1" 196 '' 0 '${(M)${:-$_p9k__keymap$_p9k__region_active}:#vicmd0}' '❮'
			_p9k_prompt_segment $0_ERROR_VIVIS "$_p9k_color1" 196 '' 0 '${(M)${:-$_p9k__keymap$_p9k__region_active}:#(vicmd1|vivis?|vivli?)}' 'Ⅴ'
		else
			if (( _POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE ))
			then
				_p9k_prompt_segment $0_OK_VIINS "$_p9k_color1" 76 '' 0 '${${:-$_p9k__keymap.$_p9k__zle_state}:#(vicmd.*|vivis.*|vivli.*|*.*overwrite*)}' '❯'
				_p9k_prompt_segment $0_OK_VIOWR "$_p9k_color1" 76 '' 0 '${${:-$_p9k__keymap.$_p9k__zle_state}:#(vicmd.*|vivis.*|vivli.*|*.*insert*)}' '▶'
			else
				_p9k_prompt_segment $0_OK_VIINS "$_p9k_color1" 76 '' 0 '${_p9k__keymap:#(vicmd|vivis|vivli)}' '❯'
			fi
			_p9k_prompt_segment $0_OK_VICMD "$_p9k_color1" 76 '' 0 '${(M)${:-$_p9k__keymap$_p9k__region_active}:#vicmd0}' '❮'
			_p9k_prompt_segment $0_OK_VIVIS "$_p9k_color1" 76 '' 0 '${(M)${:-$_p9k__keymap$_p9k__region_active}:#(vicmd1|vivis?|vivli?)}' 'Ⅴ'
		fi
	fi
	(( _p9k__has_upglob )) || _p9k__prompt_char_saved[$_p9k__prompt_side$_p9k__segment_index$((!_p9k__status))]=$_p9k__prompt[len+1,-1] 
}
prompt_proxy () {
	local -U p=($all_proxy $http_proxy $https_proxy $ftp_proxy $ALL_PROXY $HTTP_PROXY $HTTPS_PROXY $FTP_PROXY) 
	p=(${(@)${(@)${(@)p#*://}##*@}%%/*}) 
	(( $#p == 1 )) || p=("") 
	_p9k_prompt_segment $0 $_p9k_color1 blue PROXY_ICON 0 '' "$p[1]"
}
prompt_public_ip () {
	local -i len=$#_p9k__prompt _p9k__has_upglob 
	local ip='${_p9k__public_ip:-$_POWERLEVEL9K_PUBLIC_IP_NONE}' 
	if [[ -n $_POWERLEVEL9K_PUBLIC_IP_VPN_INTERFACE ]]
	then
		_p9k_prompt_segment "$0" "$_p9k_color1" "$_p9k_color2" PUBLIC_IP_ICON 1 '${_p9k__public_ip_not_vpn:+'$ip'}' $ip
		_p9k_prompt_segment "$0" "$_p9k_color1" "$_p9k_color2" VPN_ICON 1 '${_p9k__public_ip_vpn:+'$ip'}' $ip
	else
		_p9k_prompt_segment "$0" "$_p9k_color1" "$_p9k_color2" PUBLIC_IP_ICON 1 $ip $ip
	fi
	(( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}
prompt_pyenv () {
	_p9k_pyenv_compute || return
	_p9k_prompt_segment "$0" "blue" "$_p9k_color1" 'PYTHON_ICON' 0 '' "${_p9k__pyenv_version//\%/%%}"
}
prompt_ram () {
	local -i len=$#_p9k__prompt _p9k__has_upglob 
	_p9k_prompt_segment $0 yellow "$_p9k_color1" RAM_ICON 1 '$_p9k__ram_free' '$_p9k__ram_free'
	(( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}
prompt_ranger () {
	_p9k_prompt_segment $0 $_p9k_color1 yellow RANGER_ICON 0 '' $RANGER_LEVEL
}
prompt_rbenv () {
	if [[ -n $RBENV_VERSION ]]
	then
		(( ${_POWERLEVEL9K_RBENV_SOURCES[(I)shell]} )) || return
		local v=$RBENV_VERSION 
	else
		(( ${_POWERLEVEL9K_RBENV_SOURCES[(I)local|global]} )) || return
		_p9k__ret= 
		if [[ $RBENV_DIR != (|.) ]]
		then
			[[ $RBENV_DIR == /* ]] && local dir=$RBENV_DIR  || local dir="$_p9k__cwd_a/$RBENV_DIR" 
			dir=${dir:A} 
			if [[ $dir != $_p9k__cwd_a ]]
			then
				while true
				do
					if _p9k_read_word $dir/.ruby-version
					then
						(( ${_POWERLEVEL9K_RBENV_SOURCES[(I)local]} )) || return
						break
					fi
					[[ $dir == (/|.) ]] && break
					dir=${dir:h} 
				done
			fi
		fi
		if [[ -z $_p9k__ret ]]
		then
			_p9k_upglob .ruby-version
			local -i idx=$? 
			if (( idx )) && _p9k_read_word $_p9k__parent_dirs[idx]/.ruby-version
			then
				(( ${_POWERLEVEL9K_RBENV_SOURCES[(I)local]} )) || return
			else
				_p9k__ret= 
			fi
		fi
		if [[ -z $_p9k__ret ]]
		then
			(( _POWERLEVEL9K_RBENV_PROMPT_ALWAYS_SHOW )) || return
			(( ${_POWERLEVEL9K_RBENV_SOURCES[(I)global]} )) || return
			_p9k_rbenv_global_version
		fi
		local v=$_p9k__ret 
	fi
	if (( !_POWERLEVEL9K_RBENV_PROMPT_ALWAYS_SHOW ))
	then
		_p9k_rbenv_global_version
		[[ $v == $_p9k__ret ]] && return
	fi
	if (( !_POWERLEVEL9K_RBENV_SHOW_SYSTEM ))
	then
		[[ $v == system ]] && return
	fi
	_p9k_prompt_segment "$0" "red" "$_p9k_color1" 'RUBY_ICON' 0 '' "${v//\%/%%}"
}
prompt_root_indicator () {
	local -i len=$#_p9k__prompt _p9k__has_upglob 
	_p9k_prompt_segment "$0" "$_p9k_color1" "yellow" 'ROOT_ICON' 0 '${${(%):-%#}:#\%}' ''
	(( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}
prompt_rspec_stats () {
	if [[ -d app && -d spec ]]
	then
		local -a code=(app/**/*.rb(N)) 
		(( $#code )) || return
		local tests=(spec/**/*.rb(N)) 
		_p9k_build_test_stats "$0" "$#code" "$#tests" "RSpec" 'TEST_ICON'
	fi
}
prompt_rust_version () {
	unset P9K_RUST_VERSION
	if (( _POWERLEVEL9K_RUST_VERSION_PROJECT_ONLY ))
	then
		_p9k_upglob Cargo.toml && return
	fi
	local rustc=$commands[rustc] toolchain deps=() 
	if (( $+commands[ldd] ))
	then
		if ! _p9k_cache_stat_get $0_so $rustc
		then
			local line so
			for line in "${(@f)$(ldd $rustc 2>/dev/null)}"
			do
				[[ $line == (#b)[[:space:]]#librustc_driver[^[:space:]]#.so' => '(*)' (0x'[[:xdigit:]]#')' ]] || continue
				so=$match[1] 
				break
			done
			_p9k_cache_stat_set "$so"
		fi
		deps+=$_p9k__cache_val[1] 
	fi
	if (( $+commands[rustup] ))
	then
		local rustup=$commands[rustup] 
		local rustup_home=${RUSTUP_HOME:-~/.rustup} 
		local cfg=($rustup_home/settings.toml(.N)) 
		deps+=($cfg $rustup_home/update-hashes/*(.N)) 
		if [[ -z ${toolchain::=$RUSTUP_TOOLCHAIN} ]]
		then
			if ! _p9k_cache_stat_get $0_overrides $rustup $cfg
			then
				local lines=(${(f)"$(rustup override list 2>/dev/null)"}) 
				if [[ $lines[1] == "no overrides" ]]
				then
					_p9k_cache_stat_set
				else
					local MATCH
					local keys=(${(@)${lines%%[[:space:]]#[^[:space:]]#}/(#m)*/${(b)MATCH}/}) 
					local vals=(${(@)lines/(#m)*/$MATCH[(I)/] ${MATCH##*[[:space:]]}}) 
					_p9k_cache_stat_set ${keys:^vals}
				fi
			fi
			local -A overrides=($_p9k__cache_val) 
			_p9k_upglob rust-toolchain
			local dir=$_p9k__parent_dirs[$?] 
			local -i n m=${dir[(I)/]} 
			local pair
			for pair in ${overrides[(K)$_p9k__cwd/]}
			do
				n=${pair%% *} 
				(( n <= m )) && continue
				m=n 
				toolchain=${pair#* } 
			done
			if [[ -z $toolchain && -n $dir ]]
			then
				_p9k_read_word $dir/rust-toolchain
				toolchain=$_p9k__ret 
			fi
		fi
	fi
	if ! _p9k_cache_stat_get $0_v$toolchain $rustc $deps
	then
		_p9k_cache_stat_set "$($rustc --version 2>/dev/null)"
	fi
	local v=${${_p9k__cache_val[1]#rustc }%% *} 
	[[ -n $v ]] || return
	typeset -g P9K_RUST_VERSION=$_p9k__cache_val[1] 
	_p9k_prompt_segment "$0" "darkorange" "$_p9k_color1" 'RUST_ICON' 0 '' "${v//\%/%%}"
}
prompt_rvm () {
	[[ $GEM_HOME == *rvm* && $ruby_string != $rvm_path/bin/ruby ]] || return
	local v=${GEM_HOME:t} 
	(( _POWERLEVEL9K_RVM_SHOW_GEMSET )) || v=${v%%${rvm_gemset_separator:-@}*} 
	(( _POWERLEVEL9K_RVM_SHOW_PREFIX )) || v=${v#*-} 
	[[ -n $v ]] || return
	_p9k_prompt_segment "$0" "240" "$_p9k_color1" 'RUBY_ICON' 0 '' "${v//\%/%%}"
}
prompt_scalaenv () {
	if [[ -n $SCALAENV_VERSION ]]
	then
		(( ${_POWERLEVEL9K_SCALAENV_SOURCES[(I)shell]} )) || return
		local v=$SCALAENV_VERSION 
	else
		(( ${_POWERLEVEL9K_SCALAENV_SOURCES[(I)local|global]} )) || return
		_p9k__ret= 
		if [[ $SCALAENV_DIR != (|.) ]]
		then
			[[ $SCALAENV_DIR == /* ]] && local dir=$SCALAENV_DIR  || local dir="$_p9k__cwd_a/$SCALAENV_DIR" 
			dir=${dir:A} 
			if [[ $dir != $_p9k__cwd_a ]]
			then
				while true
				do
					if _p9k_read_word $dir/.scala-version
					then
						(( ${_POWERLEVEL9K_SCALAENV_SOURCES[(I)local]} )) || return
						break
					fi
					[[ $dir == (/|.) ]] && break
					dir=${dir:h} 
				done
			fi
		fi
		if [[ -z $_p9k__ret ]]
		then
			_p9k_upglob .scala-version
			local -i idx=$? 
			if (( idx )) && _p9k_read_word $_p9k__parent_dirs[idx]/.scala-version
			then
				(( ${_POWERLEVEL9K_SCALAENV_SOURCES[(I)local]} )) || return
			else
				_p9k__ret= 
			fi
		fi
		if [[ -z $_p9k__ret ]]
		then
			(( _POWERLEVEL9K_SCALAENV_PROMPT_ALWAYS_SHOW )) || return
			(( ${_POWERLEVEL9K_SCALAENV_SOURCES[(I)global]} )) || return
			_p9k_scalaenv_global_version
		fi
		local v=$_p9k__ret 
	fi
	if (( !_POWERLEVEL9K_SCALAENV_PROMPT_ALWAYS_SHOW ))
	then
		_p9k_scalaenv_global_version
		[[ $v == $_p9k__ret ]] && return
	fi
	if (( !_POWERLEVEL9K_SCALAENV_SHOW_SYSTEM ))
	then
		[[ $v == system ]] && return
	fi
	_p9k_prompt_segment "$0" "red" "$_p9k_color1" 'SCALA_ICON' 0 '' "${v//\%/%%}"
}
prompt_ssh () {
	local -i len=$#_p9k__prompt _p9k__has_upglob 
	_p9k_prompt_segment "$0" "$_p9k_color1" "yellow" 'SSH_ICON' 0 '' ''
	(( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}
prompt_status () {
	if ! _p9k_cache_get $0 $_p9k__status $_p9k__pipestatus
	then
		(( _p9k__status )) && local state=ERROR  || local state=OK 
		if (( _POWERLEVEL9K_STATUS_EXTENDED_STATES ))
		then
			if (( _p9k__status ))
			then
				if (( $#_p9k__pipestatus > 1 ))
				then
					state+=_PIPE 
				elif (( _p9k__status > 128 ))
				then
					state+=_SIGNAL 
				fi
			elif [[ "$_p9k__pipestatus" == *[1-9]* ]]
			then
				state+=_PIPE 
			fi
		fi
		_p9k__cache_val=(:) 
		if (( _POWERLEVEL9K_STATUS_$state ))
		then
			if (( _POWERLEVEL9K_STATUS_SHOW_PIPESTATUS ))
			then
				local text=${(j:|:)${(@)_p9k__pipestatus:/(#b)(*)/$_p9k_exitcode2str[$match[1]+1]}} 
			else
				local text=$_p9k_exitcode2str[_p9k__status+1] 
			fi
			if (( _p9k__status ))
			then
				if (( !_POWERLEVEL9K_STATUS_CROSS && _POWERLEVEL9K_STATUS_VERBOSE ))
				then
					_p9k__cache_val=($0_$state red yellow1 CARRIAGE_RETURN_ICON 0 '' "$text") 
				else
					_p9k__cache_val=($0_$state $_p9k_color1 red FAIL_ICON 0 '' '') 
				fi
			elif (( _POWERLEVEL9K_STATUS_VERBOSE || _POWERLEVEL9K_STATUS_OK_IN_NON_VERBOSE ))
			then
				[[ $state == OK ]] && text='' 
				_p9k__cache_val=($0_$state "$_p9k_color1" green OK_ICON 0 '' "$text") 
			fi
		fi
		if (( $#_p9k__pipestatus < 3 ))
		then
			_p9k_cache_set "${(@)_p9k__cache_val}"
		fi
	fi
	_p9k_prompt_segment "${(@)_p9k__cache_val}"
}
prompt_swap () {
	local -i len=$#_p9k__prompt _p9k__has_upglob 
	_p9k_prompt_segment $0 yellow "$_p9k_color1" SWAP_ICON 1 '$_p9k__swap_used' '$_p9k__swap_used'
	(( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}
prompt_swift_version () {
	_p9k_cached_cmd 0 '' swift --version || return
	[[ $_p9k__ret == (#b)[^[:digit:]]#([[:digit:].]##)* ]] || return
	_p9k_prompt_segment "$0" "magenta" "white" 'SWIFT_ICON' 0 '' "${match[1]//\%/%%}"
}
prompt_symfony2_tests () {
	if [[ -d src && -d app && -f app/AppKernel.php ]]
	then
		local -a all=(src/**/*.php(N)) 
		local -a code=(${(@)all##*Tests*}) 
		(( $#code )) || return
		_p9k_build_test_stats "$0" "$#code" "$(($#all - $#code))" "SF2" 'TEST_ICON'
	fi
}
prompt_symfony2_version () {
	if [[ -r app/bootstrap.php.cache ]]
	then
		local v="${$(grep -F " VERSION " app/bootstrap.php.cache 2>/dev/null)//[![:digit:].]}" 
		_p9k_prompt_segment "$0" "grey35" "$_p9k_color1" 'SYMFONY_ICON' 0 '' "${v//\%/%%}"
	fi
}
prompt_taskwarrior () {
	unset P9K_TASKWARRIOR_PENDING_COUNT P9K_TASKWARRIOR_OVERDUE_COUNT
	if ! _p9k_taskwarrior_check_data
	then
		_p9k_taskwarrior_data_files=() 
		_p9k_taskwarrior_data_non_files=() 
		_p9k_taskwarrior_data_sig= 
		_p9k_taskwarrior_counters=() 
		_p9k_taskwarrior_next_due=0 
		_p9k_taskwarrior_check_meta || _p9k_taskwarrior_init_meta || return
		_p9k_taskwarrior_init_data
	fi
	(( $#_p9k_taskwarrior_counters )) || return
	local text c=$_p9k_taskwarrior_counters[OVERDUE] 
	if [[ -n $c ]]
	then
		typeset -g P9K_TASKWARRIOR_OVERDUE_COUNT=$c 
		text+="!$c" 
	fi
	c=$_p9k_taskwarrior_counters[PENDING] 
	if [[ -n $c ]]
	then
		typeset -g P9K_TASKWARRIOR_PENDING_COUNT=$c 
		[[ -n $text ]] && text+='/' 
		text+=$c 
	fi
	[[ -n $text ]] || return
	_p9k_prompt_segment $0 6 $_p9k_color1 TASKWARRIOR_ICON 0 '' $text
}
prompt_terraform () {
	local ws=$TF_WORKSPACE 
	if [[ -z $TF_WORKSPACE ]]
	then
		_p9k_read_word ${${TF_DATA_DIR:-.terraform}:A}/environment && ws=$_p9k__ret 
	fi
	[[ -z $ws || ( $ws == default && $_POWERLEVEL9K_TERRAFORM_SHOW_DEFAULT == 0 ) ]] && return
	local pat class state
	for pat class in "${_POWERLEVEL9K_TERRAFORM_CLASSES[@]}"
	do
		if [[ $ws == ${~pat} ]]
		then
			[[ -n $class ]] && state=_${${(U)class}//İ/I} 
			break
		fi
	done
	_p9k_prompt_segment "$0$state" $_p9k_color1 blue TERRAFORM_ICON 0 '' $ws
}
prompt_terraform_version () {
	_p9k_cached_cmd 0 '' terraform --version || return
	local v=${_p9k__ret#Terraform v} 
	(( $#v < $#_p9k__ret )) || return
	v=${v%%$'\n'*} 
	[[ -n $v ]] || return
	_p9k_prompt_segment $0 $_p9k_color1 blue TERRAFORM_ICON 0 '' $v
}
prompt_time () {
	if (( _POWERLEVEL9K_EXPERIMENTAL_TIME_REALTIME ))
	then
		_p9k_prompt_segment "$0" "$_p9k_color2" "$_p9k_color1" "TIME_ICON" 0 '' "$_POWERLEVEL9K_TIME_FORMAT"
	else
		if [[ $_p9k__refresh_reason == precmd ]]
		then
			if [[ $+__p9k_instant_prompt_active == 1 && $__p9k_instant_prompt_time_format == $_POWERLEVEL9K_TIME_FORMAT ]]
			then
				_p9k__time=${__p9k_instant_prompt_time//\%/%%} 
			else
				_p9k__time=${${(%)_POWERLEVEL9K_TIME_FORMAT}//\%/%%} 
			fi
		fi
		if (( _POWERLEVEL9K_TIME_UPDATE_ON_COMMAND ))
		then
			_p9k_escape $_p9k__time
			local t=$_p9k__ret 
			_p9k_escape $_POWERLEVEL9K_TIME_FORMAT
			_p9k_prompt_segment "$0" "$_p9k_color2" "$_p9k_color1" "TIME_ICON" 1 '' "\${_p9k__line_finished-$t}\${_p9k__line_finished+$_p9k__ret}"
		else
			_p9k_prompt_segment "$0" "$_p9k_color2" "$_p9k_color1" "TIME_ICON" 0 '' $_p9k__time
		fi
	fi
}
prompt_timewarrior () {
	local -a stat
	local dir=${TIMEWARRIORDB:-~/.timewarrior}/data 
	[[ $dir == $_p9k_timewarrior_dir ]] || _p9k_timewarrior_clear
	if [[ -n $_p9k_timewarrior_file_name ]]
	then
		zstat -A stat +mtime -- $dir $_p9k_timewarrior_file_name 2> /dev/null || stat=() 
		if [[ $stat[1] == $_p9k_timewarrior_dir_mtime && $stat[2] == $_p9k_timewarrior_file_mtime ]]
		then
			if (( $+_p9k_timewarrior_tags ))
			then
				_p9k_prompt_segment $0 grey 255 TIMEWARRIOR_ICON 0 '' "${_p9k_timewarrior_tags//\%/%%}"
			fi
			return
		fi
	fi
	if [[ ! -d $dir ]]
	then
		_p9k_timewarrior_clear
		return
	fi
	_p9k_timewarrior_dir=$dir 
	if [[ $stat[1] != $_p9k_timewarrior_dir_mtime ]]
	then
		local -a files=($dir/<->-<->.data(.N)) 
		if (( ! $#files ))
		then
			if (( $#stat )) || zstat -A stat +mtime -- $dir 2> /dev/null
			then
				_p9k_timewarrior_dir_mtime=$stat[1] 
				_p9k_timewarrior_file_mtime=$stat[1] 
				_p9k_timewarrior_file_name=$dir 
				unset _p9k_timewarrior_tags
				_p9k__state_dump_scheduled=1 
			else
				_p9k_timewarrior_clear
			fi
			return
		fi
		_p9k_timewarrior_file_name=${${(AO)files}[1]} 
	fi
	if ! zstat -A stat +mtime -- $dir $_p9k_timewarrior_file_name 2> /dev/null
	then
		_p9k_timewarrior_clear
		return
	fi
	_p9k_timewarrior_dir_mtime=$stat[1] 
	_p9k_timewarrior_file_mtime=$stat[2] 
	{
		local tail=${${(Af)"$(<$_p9k_timewarrior_file_name)"}[-1]} 
	} 2> /dev/null
	if [[ $tail == (#b)'inc '[^\ ]##(|\ #\#(*)) ]]
	then
		_p9k_timewarrior_tags=${${match[2]## #}%% #} 
		_p9k_prompt_segment $0 grey 255 TIMEWARRIOR_ICON 0 '' "${_p9k_timewarrior_tags//\%/%%}"
	else
		unset _p9k_timewarrior_tags
	fi
	_p9k__state_dump_scheduled=1 
}
prompt_todo () {
	unset P9K_TODO_TOTAL_TASK_COUNT P9K_TODO_FILTERED_TASK_COUNT
	[[ -r $_p9k__todo_file && -x $_p9k__todo_command ]] || return
	if ! _p9k_cache_stat_get $0 $_p9k__todo_file
	then
		local count="$($_p9k__todo_command -p ls | command tail -1)" 
		if [[ $count == (#b)'TODO: '([[:digit:]]##)' of '([[:digit:]]##)' '* ]]
		then
			_p9k_cache_stat_set 1 $match[1] $match[2]
		else
			_p9k_cache_stat_set 0
		fi
	fi
	(( $_p9k__cache_val[1] )) || return
	typeset -gi P9K_TODO_FILTERED_TASK_COUNT=$_p9k__cache_val[2] 
	typeset -gi P9K_TODO_TOTAL_TASK_COUNT=$_p9k__cache_val[3] 
	if (( (P9K_TODO_TOTAL_TASK_COUNT    || !_POWERLEVEL9K_TODO_HIDE_ZERO_TOTAL) &&
        (P9K_TODO_FILTERED_TASK_COUNT || !_POWERLEVEL9K_TODO_HIDE_ZERO_FILTERED) ))
	then
		if (( P9K_TODO_TOTAL_TASK_COUNT == P9K_TODO_FILTERED_TASK_COUNT ))
		then
			local text=$P9K_TODO_TOTAL_TASK_COUNT 
		else
			local text="$P9K_TODO_FILTERED_TASK_COUNT/$P9K_TODO_TOTAL_TASK_COUNT" 
		fi
		_p9k_prompt_segment "$0" "grey50" "$_p9k_color1" 'TODO_ICON' 0 '' "$text"
	fi
}
prompt_toolbox () {
	_p9k_prompt_segment $0 $_p9k_color1 yellow TOOLBOX_ICON 0 '' $P9K_TOOLBOX_NAME
}
prompt_user () {
	local -i len=$#_p9k__prompt _p9k__has_upglob 
	_p9k_prompt_segment "${0}_ROOT" "${_p9k_color1}" yellow ROOT_ICON 0 '${${(%):-%#}:#\%}' "$_POWERLEVEL9K_USER_TEMPLATE"
	if [[ -n "$SUDO_COMMAND" ]]
	then
		_p9k_prompt_segment "${0}_SUDO" "${_p9k_color1}" yellow SUDO_ICON 0 '${${(%):-%#}:#\#}' "$_POWERLEVEL9K_USER_TEMPLATE"
	else
		_p9k_prompt_segment "${0}_DEFAULT" "${_p9k_color1}" yellow USER_ICON 0 '${${(%):-%#}:#\#}' "%n"
	fi
	(( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}
prompt_vcs () {
	if (( _p9k_vcs_index && $+GITSTATUS_DAEMON_PID_POWERLEVEL9K ))
	then
		_p9k__prompt+='${(e)_p9k__vcs}' 
		return
	fi
	local -a backends=($_POWERLEVEL9K_VCS_BACKENDS) 
	if (( ${backends[(I)git]} && $+GITSTATUS_DAEMON_PID_POWERLEVEL9K )) && _p9k_vcs_gitstatus
	then
		_p9k_vcs_render && return
		backends=(${backends:#git}) 
	fi
	if (( $#backends ))
	then
		VCS_WORKDIR_DIRTY=false 
		VCS_WORKDIR_HALF_DIRTY=false 
		local current_state="" 
		zstyle ':vcs_info:*' enable ${backends}
		vcs_info
		local vcs_prompt="${vcs_info_msg_0_}" 
		if [[ -n "$vcs_prompt" ]]
		then
			if [[ "$VCS_WORKDIR_DIRTY" == true ]]
			then
				current_state='MODIFIED' 
			else
				if [[ "$VCS_WORKDIR_HALF_DIRTY" == true ]]
				then
					current_state='UNTRACKED' 
				else
					current_state='CLEAN' 
				fi
			fi
			_p9k_prompt_segment "${0}_${${(U)current_state}//İ/I}" "${__p9k_vcs_states[$current_state]}" "$_p9k_color1" "$vcs_visual_identifier" 0 '' "$vcs_prompt"
		fi
	fi
}
prompt_vi_mode () {
	local -i len=$#_p9k__prompt _p9k__has_upglob 
	if (( __p9k_sh_glob ))
	then
		if (( $+_POWERLEVEL9K_VI_OVERWRITE_MODE_STRING ))
		then
			if [[ -n $_POWERLEVEL9K_VI_INSERT_MODE_STRING ]]
			then
				_p9k_prompt_segment $0_INSERT "$_p9k_color1" blue '' 0 '${${${${${${:-$_p9k__keymap.$_p9k__zle_state}:#vicmd.*}:#vivis.*}:#vivli.*}:#*.*overwrite*}}' "$_POWERLEVEL9K_VI_INSERT_MODE_STRING"
			fi
			_p9k_prompt_segment $0_OVERWRITE "$_p9k_color1" blue '' 0 '${${${${${${:-$_p9k__keymap.$_p9k__zle_state}:#vicmd.*}:#vivis.*}:#vivli.*}:#*.*insert*}}' "$_POWERLEVEL9K_VI_OVERWRITE_MODE_STRING"
		else
			if [[ -n $_POWERLEVEL9K_VI_INSERT_MODE_STRING ]]
			then
				_p9k_prompt_segment $0_INSERT "$_p9k_color1" blue '' 0 '${${${${_p9k__keymap:#vicmd}:#vivis}:#vivli}}' "$_POWERLEVEL9K_VI_INSERT_MODE_STRING"
			fi
		fi
		if (( $+_POWERLEVEL9K_VI_VISUAL_MODE_STRING ))
		then
			_p9k_prompt_segment $0_NORMAL "$_p9k_color1" white '' 0 '${(M)${:-$_p9k__keymap$_p9k__region_active}:#vicmd0}' "$_POWERLEVEL9K_VI_COMMAND_MODE_STRING"
			_p9k_prompt_segment $0_VISUAL "$_p9k_color1" white '' 0 '${$((! ${#${${${${:-$_p9k__keymap$_p9k__region_active}:#vicmd1}:#vivis?}:#vivli?}})):#0}' "$_POWERLEVEL9K_VI_VISUAL_MODE_STRING"
		else
			_p9k_prompt_segment $0_NORMAL "$_p9k_color1" white '' 0 '${$((! ${#${${${_p9k__keymap:#vicmd}:#vivis}:#vivli}})):#0}' "$_POWERLEVEL9K_VI_COMMAND_MODE_STRING"
		fi
	else
		if (( $+_POWERLEVEL9K_VI_OVERWRITE_MODE_STRING ))
		then
			if [[ -n $_POWERLEVEL9K_VI_INSERT_MODE_STRING ]]
			then
				_p9k_prompt_segment $0_INSERT "$_p9k_color1" blue '' 0 '${${:-$_p9k__keymap.$_p9k__zle_state}:#(vicmd.*|vivis.*|vivli.*|*.*overwrite*)}' "$_POWERLEVEL9K_VI_INSERT_MODE_STRING"
			fi
			_p9k_prompt_segment $0_OVERWRITE "$_p9k_color1" blue '' 0 '${${:-$_p9k__keymap.$_p9k__zle_state}:#(vicmd.*|vivis.*|vivli.*|*.*insert*)}' "$_POWERLEVEL9K_VI_OVERWRITE_MODE_STRING"
		else
			if [[ -n $_POWERLEVEL9K_VI_INSERT_MODE_STRING ]]
			then
				_p9k_prompt_segment $0_INSERT "$_p9k_color1" blue '' 0 '${_p9k__keymap:#(vicmd|vivis|vivli)}' "$_POWERLEVEL9K_VI_INSERT_MODE_STRING"
			fi
		fi
		if (( $+_POWERLEVEL9K_VI_VISUAL_MODE_STRING ))
		then
			_p9k_prompt_segment $0_NORMAL "$_p9k_color1" white '' 0 '${(M)${:-$_p9k__keymap$_p9k__region_active}:#vicmd0}' "$_POWERLEVEL9K_VI_COMMAND_MODE_STRING"
			_p9k_prompt_segment $0_VISUAL "$_p9k_color1" white '' 0 '${(M)${:-$_p9k__keymap$_p9k__region_active}:#(vicmd1|vivis?|vivli?)}' "$_POWERLEVEL9K_VI_VISUAL_MODE_STRING"
		else
			_p9k_prompt_segment $0_NORMAL "$_p9k_color1" white '' 0 '${(M)_p9k__keymap:#(vicmd|vivis|vivli)}' "$_POWERLEVEL9K_VI_COMMAND_MODE_STRING"
		fi
	fi
	(( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}
prompt_vim_shell () {
	local -i len=$#_p9k__prompt _p9k__has_upglob 
	_p9k_prompt_segment $0 green $_p9k_color1 VIM_ICON 0 '' ''
	(( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}
prompt_virtualenv () {
	local msg='' 
	if (( _POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION )) && _p9k_python_version
	then
		msg="${_p9k__ret//\%/%%} " 
	fi
	local v=${VIRTUAL_ENV:t} 
	if [[ $VIRTUAL_ENV_PROMPT == '('?*') ' && $VIRTUAL_ENV_PROMPT != "($v) " ]]
	then
		v=$VIRTUAL_ENV_PROMPT[2,-3] 
	elif [[ $v == $~_POWERLEVEL9K_VIRTUALENV_GENERIC_NAMES ]]
	then
		v=${VIRTUAL_ENV:h:t} 
	fi
	msg+="$_POWERLEVEL9K_VIRTUALENV_LEFT_DELIMITER${v//\%/%%}$_POWERLEVEL9K_VIRTUALENV_RIGHT_DELIMITER" 
	case $_POWERLEVEL9K_VIRTUALENV_SHOW_WITH_PYENV in
		(false) _p9k_prompt_segment "$0" "blue" "$_p9k_color1" 'PYTHON_ICON' 0 '${(M)${#P9K_PYENV_PYTHON_VERSION}:#0}' "$msg" ;;
		(if-different) _p9k_escape $v
			_p9k_prompt_segment "$0" "blue" "$_p9k_color1" 'PYTHON_ICON' 0 '${${:-'$_p9k__ret'}:#$_p9k__pyenv_version}' "$msg" ;;
		(*) _p9k_prompt_segment "$0" "blue" "$_p9k_color1" 'PYTHON_ICON' 0 '' "$msg" ;;
	esac
}
prompt_vpn_ip () {
	typeset -ga _p9k__vpn_ip_segments
	_p9k__vpn_ip_segments+=($_p9k__prompt_side $_p9k__line_index $_p9k__segment_index) 
	local p='${(e)_p9k__vpn_ip_'$_p9k__prompt_side$_p9k__segment_index'}' 
	_p9k__prompt+=$p 
	typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$p
}
prompt_wifi () {
	local -i len=$#_p9k__prompt _p9k__has_upglob 
	_p9k_prompt_segment $0 green $_p9k_color1 WIFI_ICON 1 '$_p9k__wifi_on' '$P9K_WIFI_LAST_TX_RATE Mbps'
	(( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}
prompt_xplr () {
	local -i len=$#_p9k__prompt _p9k__has_upglob 
	_p9k_prompt_segment $0 6 $_p9k_color1 XPLR_ICON 0 '' ''
	(( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}
pydoc () {
	python3 -m pydoc "$@"
}
pyenv_prompt_info () {
	return 1
}
rbenv_prompt_info () {
	return 1
}
recent_note () {
	cd ~/Dropbox/Medical/
	file=$(ls -lt | head -n 30 | awk '{print $NF}' | fzf --preview 'bat --style=numbers --color=always {}') 
	[ -n "$file" ] && nvim "$file"
}
regexp-replace () {
	argv=("$1" "$2" "$3") 
	4=0 
	[[ -o re_match_pcre ]] && 4=1 
	emulate -L zsh
	local MATCH MBEGIN MEND
	local -a match mbegin mend
	if (( $4 ))
	then
		zmodload zsh/pcre || return 2
		pcre_compile -- "$2" && pcre_study || return 2
		4=0 6= 
		local ZPCRE_OP
		while pcre_match -b -n $4 -- "${(P)1}"
		do
			5=${(e)3} 
			argv+=(${(s: :)ZPCRE_OP} "$5") 
			4=$((argv[-2] + (argv[-3] == argv[-2]))) 
		done
		(($# > 6)) || return
		set +o multibyte
		5= 6=1 
		for 2 3 4 in "$@[7,-1]"
		do
			5+=${(P)1[$6,$2]}$4 
			6=$(($3 + 1)) 
		done
		5+=${(P)1[$6,-1]} 
	else
		4=${(P)1} 
		while [[ -n $4 ]]
		do
			if [[ $4 =~ $2 ]]
			then
				5+=${4[1,MBEGIN-1]}${(e)3} 
				if ((MEND < MBEGIN))
				then
					((MEND++))
					5+=${4[1]} 
				fi
				4=${4[MEND+1,-1]} 
				6=1 
			else
				break
			fi
		done
		[[ -n $6 ]] || return
		5+=$4 
	fi
	eval $1=\$5
}
reloadiCloud () {
	killall bird
	killall cloudd
}
remind () {
	if ! command -v reminders > /dev/null 2>&1
	then
		echo "reminders 未安裝" >&2
		return 1
	fi
	local list=${3:-Inbox} 
	reminders add "$list" "$1" --due-date "$2"
}
rename_in_sqb () {
	for file in *[*]*.txt
	do
		newname=$(echo "$file" | sed -E 's/\[[^]]*\]//g') 
		mv -iv "$file" "$newname"
	done
}
rga-fzf () {
	RG_PREFIX="rga --files-with-matches" 
	local file
	file="$(
    FZF_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
      fzf --sort --preview="[[ ! -z {} ]] && rga --pretty --context 5 {q} {}" \
      --phony -q "$1" \
      --bind "change:reload:$RG_PREFIX {q}" \
      --preview-window="70%:wrap"
  )"  && echo "opening $file" && open "$file"
}
rgnv () {
	rg_prefix='rg -i --column --line-number --no-heading --sort=modified --color=always --smart-case --glob "*.md" --max-depth 1' 
	local result=$(fzf --bind "start:reload($rg_prefix '' | uniq)" \
    --bind "change:reload($rg_prefix {q} | uniq || true)" \
    --bind "enter:execute(echo {} | tee /tmp/fzf_result)+abort" \
    --ansi --disabled \
    --height 80% --layout=reverse \
    --exit-0) 
	if [ -s /tmp/fzf_result ]
	then
		local result=$(cat /tmp/fzf_result) 
		local filename=$(echo $result | cut -d':' -f1) 
		local number=$(echo $result | sed 's/^[^:]*://; s/:.*//') 
		rm -i -f /tmp/fzf_result
		nvim +$number "$filename"
	fi
}
rgtodo () {
	rg_prefix='rg -i --column --line-number --no-heading --sort=modified --color=always --smart-case --glob "*.md" "TODO:"' 
	local result=$(fzf --bind "start:reload($rg_prefix '' | uniq)" \
    --bind "change:reload($rg_prefix {q} | uniq || true)" \
    --bind "enter:execute(echo {} | tee /tmp/fzf_result)+abort" \
    --ansi --disabled \
    --height 80% --layout=reverse \
    --exit-0) 
	if [ -s /tmp/fzf_result ]
	then
		local result=$(cat /tmp/fzf_result) 
		local filename=$(echo $result | cut -d':' -f1) 
		local number=$(echo $result | sed 's/^[^:]*://; s/:.*//') 
		rm -i -f /tmp/fzf_result
		nvim +$number "$filename"
	fi
}
ruby_prompt_info () {
	echo $(rvm_prompt_info || rbenv_prompt_info || chruby_prompt_info)
}
rvm_prompt_info () {
	[ -f $HOME/.rvm/bin/rvm-prompt ] || return 1
	local rvm_prompt
	rvm_prompt=$($HOME/.rvm/bin/rvm-prompt ${=ZSH_THEME_RVM_PROMPT_OPTIONS} 2>/dev/null) 
	[[ -z "${rvm_prompt}" ]] && return 1
	echo "${ZSH_THEME_RUBY_PROMPT_PREFIX}${rvm_prompt:gs/%/%%}${ZSH_THEME_RUBY_PROMPT_SUFFIX}"
}
simplenote () {
	nvim -c "SimplenoteList"
}
slide () {
	cd ~/Dropbox/slides/contents
	(
		check_and_start_marp_serve > /dev/null 2>&1 &
	)
	FILE=$(find . \
    -path ./node_modules \
    -prune -o -type f -name "*.md" -print |
    sed 's|^\./||' |
    fzf-pre) 
	if [ -n "$FILE" ]
	then
		(
			open "http://localhost:8080/$FILE" &
		)
		nvim +10 "$FILE"
	else
		echo "苟日新，日日新，又日新。"
	fi
}
snippets () {
	nvim $HOME/.dotfiles/neovim/snippets/init.lua
}
spectrum_bls () {
	setopt localoptions nopromptsubst
	local ZSH_SPECTRUM_TEXT=${ZSH_SPECTRUM_TEXT:-Arma virumque cano Troiae qui primus ab oris} 
	for code in {000..255}
	do
		print -P -- "$code: ${BG[$code]}${ZSH_SPECTRUM_TEXT}%{$reset_color%}"
	done
}
spectrum_ls () {
	setopt localoptions nopromptsubst
	local ZSH_SPECTRUM_TEXT=${ZSH_SPECTRUM_TEXT:-Arma virumque cano Troiae qui primus ab oris} 
	for code in {000..255}
	do
		print -P -- "$code: ${FG[$code]}${ZSH_SPECTRUM_TEXT}%{$reset_color%}"
	done
}
sss () {
	$HOME/Dropbox/Medical/scripts/ls.sh
}
start_fetch_mcp () {
	local TARGET_DIR="/Users/htlin/fetch-mcp" 
	if [ ! -d "$TARGET_DIR" ]
	then
		echo "Error: Directory $TARGET_DIR does not exist."
		return 1
	fi
	cd "$TARGET_DIR" || return 1
	nohup pnpm start > pnpm.log 2>&1 &
	disown
	echo "pnpm started in background. Logs: $TARGET_DIR/pnpm.log"
}
study () {
	cd ~/Dropbox/Medical/
	(
		python3 ~/Dropbox/scripts/gen_recent_list.py &
	)
	FILE=$(find . -type f -name "*.md" | sed 's|^\./||' | fzf-pre) 
	if [ -n "$FILE" ]
	then
		nvim +10 "$FILE"
	else
		echo "獨學而無友，則孤陋而寡聞"
	fi
}
studyrg () {
	cd ~/Dropbox/Medical/
	rgnv
}
svn_prompt_info () {
	return 1
}
syncq () {
	RED='\033[0;31m' 
	GREEN='\033[0;32m' 
	YELLOW='\033[1;33m' 
	NC='\033[0m' 
	printf "${YELLOW}Are you sure you want to sync the files? (y/n)${NC} "
	read confirm
	if [ "$confirm" = "y" ]
	then
		printf "${GREEN}Syncing files...${NC}\n"
		rsync -av --exclude '.*' /Users/htlin/quarto-revealjs-starter/_extensions /Users/htlin/quarto-revealjs-starter/assets /Users/htlin/quarto-revealjs-starter/_quarto.yml ./
		printf "${GREEN}Sync complete.${NC}\n"
	else
		printf "${RED}Sync canceled.${NC}\n"
	fi
}
take () {
	if [[ $1 =~ ^(https?|ftp).*\.(tar\.(gz|bz2|xz)|tgz)$ ]]
	then
		takeurl "$1"
	elif [[ $1 =~ ^([A-Za-z0-9]\+@|https?|git|ssh|ftps?|rsync).*\.git/?$ ]]
	then
		takegit "$1"
	else
		takedir "$@"
	fi
}
takedir () {
	mkdir -p $@ && cd ${@:$#}
}
takegit () {
	git clone "$1"
	cd "$(basename ${1%%.git})"
}
takeurl () {
	local data thedir
	data="$(mktemp)" 
	curl -L "$1" > "$data"
	tar xf "$data"
	thedir="$(tar tf "$data" | head -n 1)" 
	rm "$data"
	cd "$thedir"
}
td () {
	[ -f ./todo.txt ] || touch ./todo.txt
	if git rev-parse --is-inside-work-tree > /dev/null 2>&1
	then
		grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox} -qxF "todo.txt" .gitignore || echo "todo.txt" >> .gitignore
	fi
	pter ./todo.txt
}
textexpand () {
	cd ~/.config/espanso/match
}
tf_prompt_info () {
	return 1
}
timezsh () {
	shell=${1-$SHELL} 
	for i in $(seq 1 4)
	do
		/usr/bin/time $shell -i -c exit
	done
}
title () {
	setopt localoptions nopromptsubst
	[[ -n "${INSIDE_EMACS:-}" && "$INSIDE_EMACS" != vterm ]] && return
	: ${2=$1}
	case "$TERM" in
		(cygwin | xterm* | putty* | rxvt* | konsole* | ansi | mlterm* | alacritty | st* | foot | contour*) print -Pn "\e]2;${2:q}\a"
			print -Pn "\e]1;${1:q}\a" ;;
		(screen* | tmux*) print -Pn "\ek${1:q}\e\\" ;;
		(*) if [[ "$TERM_PROGRAM" == "iTerm.app" ]]
			then
				print -Pn "\e]2;${2:q}\a"
				print -Pn "\e]1;${1:q}\a"
			else
				if (( ${+terminfo[fsl]} && ${+terminfo[tsl]} ))
				then
					print -Pn "${terminfo[tsl]}$1${terminfo[fsl]}"
				fi
			fi ;;
	esac
}
topdf () {
	if [ $# -eq 0 ]
	then
		echo "Usage: convert_to_pdf <file1> [file2 ...]"
		return 1
	fi
	for file in "$@"
	do
		if [ -f "$file" ]
		then
			soffice --headless --convert-to pdf "$file"
			echo "Converted $file to PDF."
		else
			echo "File $file not found."
		fi
	done
}
toslides () {
	local fontsize=${1:-72} 
	local foldername="${PWD##*/}" 
	local output="${foldername}_slides.pdf" 
	local tmp_prefix="wm_" 
	local exts=("jpg" "png" "JPG" "PNG") 
	local has_images=false 
	for ext in "${exts[@]}"
	do
		for img in *."$ext"
		do
			[[ -e "$img" ]] || continue
			has_images=true 
			break 2
		done
	done
	if ! $has_images
	then
		echo "⚠️ No .jpg or .png files found in current directory."
		return 1
	fi
	echo "🔧 Adding filename watermark with font size $fontsize..."
	for ext in "${exts[@]}"
	do
		for img in *."$ext"
		do
			[[ -e "$img" ]] || continue
			local out="${tmp_prefix}${img}" 
			magick "$img" -gravity southeast -pointsize $fontsize -fill white -undercolor black -annotate +20+20 "$img" "$out"
		done
	done
	echo "🧾 Combining into $output..."
	img2pdf ${tmp_prefix}* -o "$output" --auto-orient
	echo "🧹 Cleaning up..."
	rm -i -f ${tmp_prefix}*
	echo "✅ Done! Output: $output"
}
transcribe_audio () {
	local file_path=$1 
	local file_name=$(basename "$file_path") 
	local output_file="${file_name}.txt" 
	curl --request POST --url https://api.openai.com/v1/audio/transcriptions --header "Authorization: Bearer $OPENAI_API_KEY" --header "Content-Type: multipart/form-data" --form file=@${file_path} --form model=whisper-1 | jq -r '.text' > "${output_file}"
	cat $output_file | pbcopy
	bat $output_file
}
tre () {
	command tre "$@" -e && source "/tmp/tre_aliases_$USER" 2> /dev/null
}
try_alias_value () {
	alias_value "$1" || echo "$1"
}
unblock () {
	sudo xattr -r -d com.apple.quarantine "$@"
}
undelfile () {
	mv -iv -i ~/.Trash/files/$@ ./
}
uninstall_oh_my_zsh () {
	command env ZSH="$ZSH" sh "$ZSH/tools/uninstall.sh"
}
unlock () {
	sh /Users/htlin/.dotfiles/shellscripts/do_not_block_app.sh
}
up-line-or-beginning-search () {
	# undefined
	builtin autoload -XU
}
upgrade_oh_my_zsh () {
	echo "${fg[yellow]}Note: \`$0\` is deprecated. Use \`omz update\` instead.$reset_color" >&2
	omz update
}
uvv () {
	uvv_check || return 1
	case "$1" in
		(create) shift
			uvv_create "$@" ;;
		(remove) shift
			uvv_remove "$@" ;;
		(list) uvv_list ;;
		(activate) shift
			uvv_activate "$@" ;;
		(install) shift
			uvv_install "$@" ;;
		(deactivate) uvv_deactivate ;;
		(help) uvv_help ;;
		(*) echo "Unsupported command: $1"
			echo "Run 'uvv help' for usage"
			return 1 ;;
	esac
}
uvv_activate () {
	if [ -z "$1" ]
	then
		echo "Usage: uvv activate <uv_environment>"
		return 1
	fi
	uv_environment="$1" 
	if [ ! -d "$HOME"/.venv/"$uv_environment" ]
	then
		echo "uv environment $uv_environment does not exist"
		return 1
	fi
	uvv_deactivate
	if [ -f "$HOME"/.venv/"$uv_environment"/bin/activate ]
	then
		source "$HOME"/.venv/"$uv_environment"/bin/activate
	elif [ -f "$HOME"/.venv/"$uv_environment"/Scripts/activate ]
	then
		source "$HOME"/.venv/"$uv_environment"/Scripts/activate
	else
		echo "Error: Failed to activate uv environment" >&2
		return 1
	fi
	echo "Activated uv environment: $uv_environment"
}
uvv_check () {
	if ! command -v conda &> /dev/null
	then
		echo "Error: conda is not installed" >&2
		return 1
	fi
	if ! command -v uv &> /dev/null
	then
		echo "Error: uv is not installed" >&2
		return 1
	fi
}
uvv_create () {
	while getopts ":n:p:" opt
	do
		case $opt in
			(n) uv_environment="$OPTARG"  ;;
			(p) python_version="$OPTARG"  ;;
			(\?) echo "Invalid option -$OPTARG" >&2
				return 1 ;;
		esac
	done
	if [ -d "$HOME"/.venv/"$uv_environment" ]
	then
		echo "uv environment $uv_environment already exists"
		return 1
	fi
	if [ -z "$uv_environment" ] || [ -z "$python_version" ]
	then
		echo "Usage: uvv create -n <uv_environment> -p <python_version>"
		return 1
	fi
	env_name="uv_${python_version//./}" 
	if ! conda info --envs | grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox} -q "$env_name"
	then
		echo "Creating conda environment: $env_name"
		if ! conda create -n "$env_name" python="$python_version" -y
		then
			echo "Error: Failed to create conda environment" >&2
			return 1
		fi
	fi
	(
		echo "Activating conda environment: $env_name"
		conda activate "$env_name"
		temp=$(pwd) 
		mkdir -p -p "$HOME"/.venv || return 1
		cd "$HOME"/.venv || return 1
		uv venv "$uv_environment" --seed -p "$python_version" || return 1
		conda deactivate
		cd "$temp" || return 1
	)
	echo "Environment setup complete for uv environment: $uv_environment with Python $python_version"
	echo "Run 'uvv activate $uv_environment' to activate the environment"
}
uvv_deactivate () {
	if [ -z "$VIRTUAL_ENV" ]
	then
		echo "No uv environment is currently activated"
		return 1
	fi
	echo "Deactivated uv environment: $VIRTUAL_ENV"
	deactivate
}
uvv_help () {
	echo "Usage: uvv <command> [<args>]"
	echo "Commands:"
	echo "  create -n <uv_environment> -p <python_version>"
	echo "  remove <uv_environment>"
	echo "  list"
	echo "  activate <uv_environment>"
	echo "  install <package>"
	echo "  deactivate"
}
uvv_install () {
	if [ -z "$VIRTUAL_ENV" ]
	then
		echo "No uv environment is currently activated"
		return 1
	fi
	uv pip install "$@"
}
uvv_list () {
	if [ -z "$(ls -A "$HOME"/.venv)" ]
	then
		echo "No uv environment found"
	else
		lsd -1 -1 "$HOME"/.venv
	fi
}
uvv_remove () {
	if [ -z "$1" ]
	then
		echo "Usage: uvv remove <uv_environment>"
		return 1
	fi
	uv_environment="$1" 
	if [ ! -d "$HOME"/.venv/"$uv_environment" ]
	then
		echo "uv environment $uv_environment does not exist"
		return 1
	fi
	uvv_deactivate
	echo "Removing uv environment: $uv_environment"
	rm -i -rf "$HOME"/.venv/"$uv_environment"
	echo "uv environment $uv_environment removed"
}
vi_mode_prompt_info () {
	return 1
}
vimconfig () {
	cd ~/.config/nvim/lua/
	nvim ~/.config/nvim/lua/options.lua
}
vimfzf () {
	nvim "$(fzf-pre)"
}
virtualenv_prompt_info () {
	return 1
}
work_in_progress () {
	command git -c log.showSignature=false log -n 1 2> /dev/null | grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox} -q -- "--wip--" && echo "WIP!!"
}
xdgopen () {
	open "$1" &> /dev/null &
}
ya () {
	local tmp="$(mktemp -t "yazi-cwd.XXXXX")" 
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")"  && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]
	then
		cd -- "$cwd"
	fi
	rm -i -f -- "$tmp"
}
ygit () {
	git add -A
	git commit -m "Routine: Upload"
	git push
}
yt-list-cookies () {
	yt-dlp "$1" -o "%(playlist)s/%(playlist_index)s_%(title)s.%(ext)s" --cookies-from-browser edge
}
yt-mp3 () {
	yt-dlp --extract-audio --audio-format mp3 $1
}
yt-mp3-list () {
	folder_name=$(basename "$(pwd)") 
	yt-dlp --extract-audio --audio-format mp3 $(pbpaste) -o "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s"
}
yt-playlist () {
	yt-dlp "$1" -o "%(playlist)s/%(playlist_index)s_%(title)s.%(ext)s"
}
zgit () {
	git add -A
	aicommits --type conventional
	git push
}
zle-line-finish () {
	echoti rmkx
}
zle-line-init () {
	echoti smkx
}
zrecompile () {
	setopt localoptions extendedglob noshwordsplit noksharrays
	local opt check quiet zwc files re file pre ret map tmp mesg pats
	tmp=() 
	while getopts ":tqp" opt
	do
		case $opt in
			(t) check=yes  ;;
			(q) quiet=yes  ;;
			(p) pats=yes  ;;
			(*) if [[ -n $pats ]]
				then
					tmp=($tmp $OPTARG) 
				else
					print -u2 zrecompile: bad option: -$OPTARG
					return 1
				fi ;;
		esac
	done
	shift OPTIND-${#tmp}-1
	if [[ -n $check ]]
	then
		ret=1 
	else
		ret=0 
	fi
	if [[ -n $pats ]]
	then
		local end num
		while (( $# ))
		do
			end=$argv[(i)--] 
			if [[ end -le $# ]]
			then
				files=($argv[1,end-1]) 
				shift end
			else
				files=($argv) 
				argv=() 
			fi
			tmp=() 
			map=() 
			OPTIND=1 
			while getopts :MR opt $files
			do
				case $opt in
					([MR]) map=(-$opt)  ;;
					(*) tmp=($tmp $files[OPTIND])  ;;
				esac
			done
			shift OPTIND-1 files
			(( $#files )) || continue
			files=($files[1] ${files[2,-1]:#*(.zwc|~)}) 
			(( $#files )) || continue
			zwc=${files[1]%.zwc}.zwc 
			shift 1 files
			(( $#files )) || files=(${zwc%.zwc}) 
			if [[ -f $zwc ]]
			then
				num=$(zcompile -t $zwc | wc -l) 
				if [[ num-1 -ne $#files ]]
				then
					re=yes 
				else
					re= 
					for file in $files
					do
						if [[ $file -nt $zwc ]]
						then
							re=yes 
							break
						fi
					done
				fi
			else
				re=yes 
			fi
			if [[ -n $re ]]
			then
				if [[ -n $check ]]
				then
					[[ -z $quiet ]] && print $zwc needs re-compilation
					ret=0 
				else
					[[ -z $quiet ]] && print -n "re-compiling ${zwc}: "
					if [[ -z "$quiet" ]] && {
							[[ ! -f $zwc ]] || mv -f $zwc ${zwc}.old
						} && zcompile $map $tmp $zwc $files
					then
						print succeeded
					elif ! {
							{
								[[ ! -f $zwc ]] || mv -f $zwc ${zwc}.old
							} && zcompile $map $tmp $zwc $files 2> /dev/null
						}
					then
						[[ -z $quiet ]] && print "re-compiling ${zwc}: failed"
						ret=1 
					fi
				fi
			fi
		done
		return ret
	fi
	if (( $# ))
	then
		argv=(${^argv}/*.zwc(ND) ${^argv}.zwc(ND) ${(M)argv:#*.zwc}) 
	else
		argv=(${^fpath}/*.zwc(ND) ${^fpath}.zwc(ND) ${(M)fpath:#*.zwc}) 
	fi
	argv=(${^argv%.zwc}.zwc) 
	for zwc
	do
		files=(${(f)"$(zcompile -t $zwc)"}) 
		if [[ $files[1] = *\(mapped\)* ]]
		then
			map=-M 
			mesg='succeeded (old saved)' 
		else
			map=-R 
			mesg=succeeded 
		fi
		if [[ $zwc = */* ]]
		then
			pre=${zwc%/*}/ 
		else
			pre= 
		fi
		if [[ $files[1] != *$ZSH_VERSION ]]
		then
			re=yes 
		else
			re= 
		fi
		files=(${pre}${^files[2,-1]:#/*} ${(M)files[2,-1]:#/*}) 
		[[ -z $re ]] && for file in $files
		do
			if [[ $file -nt $zwc ]]
			then
				re=yes 
				break
			fi
		done
		if [[ -n $re ]]
		then
			if [[ -n $check ]]
			then
				[[ -z $quiet ]] && print $zwc needs re-compilation
				ret=0 
			else
				[[ -z $quiet ]] && print -n "re-compiling ${zwc}: "
				tmp=(${^files}(N)) 
				if [[ $#tmp -ne $#files ]]
				then
					[[ -z $quiet ]] && print 'failed (missing files)'
					ret=1 
				else
					if [[ -z "$quiet" ]] && mv -f $zwc ${zwc}.old && zcompile $map $zwc $files
					then
						print $mesg
					elif ! {
							mv -f $zwc ${zwc}.old && zcompile $map $zwc $files 2> /dev/null
						}
					then
						[[ -z $quiet ]] && print "re-compiling ${zwc}: failed"
						ret=1 
					fi
				fi
			fi
		fi
	done
	return ret
}
zsh_stats () {
	fc -l 1 | awk '{ CMD[$2]++; count++; } END { for (a in CMD) print CMD[a] " " CMD[a]*100/count "% " a }' | grep -v "./" | sort -nr | head -n 20 | column -c3 -s " " -t | nl
}
# Shell Options
setopt alwaystoend
setopt autocd
setopt autopushd
setopt nobeep
setopt completeinword
setopt extendedhistory
setopt noflowcontrol
setopt nohashdirs
setopt histexpiredupsfirst
setopt histignorealldups
setopt histignoredups
setopt histignorespace
setopt histverify
setopt incappendhistory
setopt interactivecomments
setopt login
setopt longlistjobs
setopt nonomatch
setopt promptsubst
setopt pushdignoredups
setopt pushdminus
setopt pushdsilent
setopt sharehistory
# Aliases
alias -- -='cd -'
alias -- ...=../..
alias -- ....=../../..
alias -- .....=../../../..
alias -- ......=../../../../..
alias -- 1='cd -1'
alias -- 2='cd -2'
alias -- 3='cd -3'
alias -- 4='cd -4'
alias -- 5='cd -5'
alias -- 6='cd -6'
alias -- 7='cd -7'
alias -- 8='cd -8'
alias -- 9='cd -9'
alias -- _='sudo '
alias -- artifact='cd ~/claude_lab/src/ && vim ~/claude_lab/src/App.jsx'
alias -- asco='yazi ~/Documents/textbook/ASCO-SEP/'
alias -- ash='yazi ~/Documents/textbook/8th\ ASH-SEP/'
alias -- ask='~/.local/pipx/venvs/gpt-command-line/bin/gpt -p'
alias -- bam-less=sam-less
alias -- bc='bc --quiet <(echo "scale=5;print\"scale=5\n\"")'
alias -- bed-less='source-highlight     -f esc --lang-def=bed.lang     --outlang-def=bioSyntax.outlang     --style-file=sam.style   | less'
alias -- bm='vim $DOTFILES/bookmark.zsh'
alias -- br=broot
alias -- brewcask='brew install --cask --no-quarantine'
alias -- brewdump='brew bundle dump --describe --force'
alias -- c=clear
alias -- cd..='cd ..'
alias -- cdropbox='cd /Users/htlin/Library/CloudStorage/Dropbox/'
alias -- claupub='npm run build && netlify deploy --prod --dir=dist'
alias -- claupub_lab='cd ~/claude_lab && npm run build && netlify deploy --prod --dir=dist'
alias -- clens=csvlens
alias -- clustal-less='source-highlight -f esc --lang-def=clustal.lang --outlang-def=bioSyntax.outlang     --style-file=fasta.style | less'
alias -- cover='nvim +10 ~/Dropbox/slides/cover.md'
alias -- cp='cp -ivr'
alias -- demo='cd ~/Dropbox/scripts/demo'
alias -- disk=diskonaut
alias -- dj='curl -s -H '\''Accept: application/json'\'' https://icanhazdadjoke.com/ | jq -r '\''.joke'\'
alias -- dpdf='sh /Users/htlin/.dotfiles/shellscripts/rename_by_chatGPT.sh'
alias -- dr=drafts
alias -- dtc='tmux detach-client'
alias -- e=exit
alias -- e2u='python /Users/htlin/pyscripts/emoji2utf8.py '
alias -- ec=echo
alias -- egrep='grep -E --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox}'
alias -- f=fix
alias -- fa-less='source-highlight      -f esc --lang-def=fasta.lang   --outlang-def=bioSyntax.outlang     --style-file=fasta.style | less'
alias -- fai-less='source-highlight      -f esc --lang-def=faidx.lang    --outlang-def=bioSyntax.outlang   --style-file=sam.style   | less'
alias -- fdfzf='fd --type f | fzf --preview '\''bat --style=numbers --color=always {}'\'
alias -- ff=fleet_of_thought
alias -- ffmpeg=ffmpeg-bar
alias -- fgrep='grep -F --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox}'
alias -- flagstat-less='source-highlight -f esc --lang-def=flagstat.lang --outlang-def=bioSyntax.outlang   --style-file=sam.style   | less'
alias -- flash=make_flashcard
alias -- forgit=git-forgit
alias -- fq-less='source-highlight      -f esc --lang-def=fastq.lang   --outlang-def=bioSyntax.outlang     --style-file=fasta.style | less'
alias -- fsh-alias=fast-theme
alias -- g=git
alias -- ga='git add'
alias -- gaa='git add --all'
alias -- gam='git am'
alias -- gama='git am --abort'
alias -- gamc='git am --continue'
alias -- gams='git am --skip'
alias -- gamscp='git am --show-current-patch'
alias -- gap='git apply'
alias -- gapa='git add --patch'
alias -- gapt='git apply --3way'
alias -- garden=publi.sh
alias -- gau='git add --update'
alias -- gav='git add --verbose'
alias -- gb='git branch'
alias -- gbD='git branch --delete --force'
alias -- gba='git branch --all'
alias -- gbd='git branch --delete'
alias -- gbda='git branch --no-color --merged | command grep -vE "^([+*]|\s*($(git_main_branch)|$(git_develop_branch))\s*$)" | command xargs git branch --delete 2>/dev/null'
alias -- gbg='git branch -vv | grep ": gone\]"'
alias -- gbgD='git branch --no-color -vv | grep ": gone\]" | awk '\''{print $1}'\'' | xargs git branch -D'
alias -- gbgd='git branch --no-color -vv | grep ": gone\]" | awk '\''{print $1}'\'' | xargs git branch -d'
alias -- gbl='git blame -b -w'
alias -- gbnm='git branch --no-merged'
alias -- gbr='git branch --remote'
alias -- gbs='git bisect'
alias -- gbsb='git bisect bad'
alias -- gbsg='git bisect good'
alias -- gbsr='git bisect reset'
alias -- gbss='git bisect start'
alias -- gc='git commit --verbose'
alias -- gc!='git commit --verbose --amend'
alias -- gca='git commit --verbose --all'
alias -- gca!='git commit --verbose --all --amend'
alias -- gcam='git commit --all --message'
alias -- gcan!='git commit --verbose --all --no-edit --amend'
alias -- gcans!='git commit --verbose --all --signoff --no-edit --amend'
alias -- gcas='git commit --all --signoff'
alias -- gcasm='git commit --all --signoff --message'
alias -- gcb='git checkout -b'
alias -- gcd='git checkout $(git_develop_branch)'
alias -- gcf='git config --list'
alias -- gcl='git clone --recurse-submodules'
alias -- gclean='git clean --interactive -d'
alias -- gcm='git checkout $(git_main_branch)'
alias -- gcmsg='git commit --message'
alias -- gcn!='git commit --verbose --no-edit --amend'
alias -- gco='git checkout'
alias -- gcor='git checkout --recurse-submodules'
alias -- gcount='git shortlog --summary --numbered'
alias -- gcp='git cherry-pick'
alias -- gcpa='git cherry-pick --abort'
alias -- gcpc='git cherry-pick --continue'
alias -- gcs='git commit --gpg-sign'
alias -- gcsm='git commit --signoff --message'
alias -- gcss='git commit --gpg-sign --signoff'
alias -- gcssm='git commit --gpg-sign --signoff --message'
alias -- gd='git diff'
alias -- gdca='git diff --cached'
alias -- gdct='git describe --tags $(git rev-list --tags --max-count=1)'
alias -- gdcw='git diff --cached --word-diff'
alias -- gds='git diff --staged'
alias -- gdt='git diff-tree --no-commit-id --name-only -r'
alias -- gdup='git diff @{upstream}'
alias -- gdw='git diff --word-diff'
alias -- gf='git fetch'
alias -- gfa='git fetch --all --prune --jobs=10'
alias -- gfg='git ls-files | grep'
alias -- gfo='git fetch origin'
alias -- gg='git gui citool'
alias -- gga='git gui citool --amend'
alias -- ggpull='git pull origin "$(git_current_branch)"'
alias -- ggpur=ggu
alias -- ggpush='git push origin "$(git_current_branch)"'
alias -- ggsup='git branch --set-upstream-to=origin/$(git_current_branch)'
alias -- gh='op plugin run -- gh'
alias -- ghh='git help'
alias -- gignore='git update-index --assume-unchanged'
alias -- gignored='git ls-files -v | grep "^[[:lower:]]"'
alias -- git-svn-dcommit-push='git svn dcommit && git push github $(git_main_branch):svntrunk'
alias -- gk='\gitk --all --branches &!'
alias -- gke='\gitk --all $(git log --walk-reflogs --pretty=%h) &!'
alias -- gl='git pull'
alias -- glg='git log --stat'
alias -- glgg='git log --graph'
alias -- glgga='git log --graph --decorate --all'
alias -- glgm='git log --graph --max-count=10'
alias -- glgp='git log --stat --patch'
alias -- glo='git log --oneline --decorate'
alias -- glod='git log --graph --pretty='\''%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset'\'
alias -- glods='git log --graph --pretty='\''%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset'\'' --date=short'
alias -- glog='git log --oneline --decorate --graph'
alias -- gloga='git log --oneline --decorate --graph --all'
alias -- glol='git log --graph --pretty='\''%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset'\'
alias -- glola='git log --graph --pretty='\''%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset'\'' --all'
alias -- glols='git log --graph --pretty='\''%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset'\'' --stat'
alias -- glp=_git_log_prettily
alias -- gluc='git pull upstream $(git_current_branch)'
alias -- glum='git pull upstream $(git_main_branch)'
alias -- gm='git merge'
alias -- gma='git merge --abort'
alias -- gmom='git merge origin/$(git_main_branch)'
alias -- gms='git merge --squash'
alias -- gmtl='git mergetool --no-prompt'
alias -- gmtlvim='git mergetool --no-prompt --tool=vimdiff'
alias -- gmum='git merge upstream/$(git_main_branch)'
alias -- googledrive='cd /Users/htlin/Library/CloudStorage/GoogleDrive-ppoiu87@gmail.com/我的雲端硬碟'
alias -- gp='git push'
alias -- gpd='git push --dry-run'
alias -- gpf='git push --force-with-lease --force-if-includes'
alias -- gpf!='git push --force'
alias -- gpoat='git push origin --all && git push origin --tags'
alias -- gpod='git push origin --delete'
alias -- gpr='git pull --rebase'
alias -- gpristine='git reset --hard && git clean --force -dfx'
alias -- gpsup='git push --set-upstream origin $(git_current_branch)'
alias -- gpsupf='git push --set-upstream origin $(git_current_branch) --force-with-lease --force-if-includes'
alias -- gpu='git push upstream'
alias -- gpv='git push --verbose'
alias -- gr='git remote'
alias -- gra='git remote add'
alias -- grb='git rebase'
alias -- grba='git rebase --abort'
alias -- grbc='git rebase --continue'
alias -- grbd='git rebase $(git_develop_branch)'
alias -- grbi='git rebase --interactive'
alias -- grbm='git rebase $(git_main_branch)'
alias -- grbo='git rebase --onto'
alias -- grbom='git rebase origin/$(git_main_branch)'
alias -- grbs='git rebase --skip'
alias -- grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox}'
alias -- grev='git revert'
alias -- grh='git reset'
alias -- grhh='git reset --hard'
alias -- grm='git rm'
alias -- grmc='git rm --cached'
alias -- grmv='git remote rename'
alias -- groh='git reset origin/$(git_current_branch) --hard'
alias -- grrm='git remote remove'
alias -- grs='git restore'
alias -- grset='git remote set-url'
alias -- grss='git restore --source'
alias -- grst='git restore --staged'
alias -- grt='cd "$(git rev-parse --show-toplevel || echo .)"'
alias -- gru='git reset --'
alias -- grup='git remote update'
alias -- grv='git remote --verbose'
alias -- gsb='git status --short --branch'
alias -- gsd='git svn dcommit'
alias -- gsh='git show'
alias -- gsi='git submodule init'
alias -- gsps='git show --pretty=short --show-signature'
alias -- gsr='git svn rebase'
alias -- gss='git status --short'
alias -- gst='git status'
alias -- gsta='git stash push'
alias -- gstaa='git stash apply'
alias -- gstall='git stash --all'
alias -- gstc='git stash clear'
alias -- gstd='git stash drop'
alias -- gstl='git stash list'
alias -- gstp='git stash pop'
alias -- gsts='git stash show --text'
alias -- gstu='gsta --include-untracked'
alias -- gsu='git submodule update'
alias -- gsw='git switch'
alias -- gswc='git switch --create'
alias -- gswd='git switch $(git_develop_branch)'
alias -- gswm='git switch $(git_main_branch)'
alias -- gtf-less='source-highlight     -f esc --lang-def=gtf.lang     --outlang-def=bioSyntax-vcf.outlang --style-file=vcf.style   | less'
alias -- gtl='gtl(){ git tag --sort=-v:refname -n --list "${1}*" }; noglob gtl'
alias -- gts='git tag --sign'
alias -- gtv='git tag | sort -V'
alias -- gunignore='git update-index --no-assume-unchanged'
alias -- gunwip='git rev-list --max-count=1 --format="%s" HEAD | grep -q "\--wip--" && git reset HEAD~1'
alias -- gup='git pull --rebase'
alias -- gupa='git pull --rebase --autostash'
alias -- gupav='git pull --rebase --autostash --verbose'
alias -- gupom='git pull --rebase origin $(git_main_branch)'
alias -- gupomi='git pull --rebase=interactive origin $(git_main_branch)'
alias -- gupv='git pull --rebase --verbose'
alias -- gwch='git whatchanged -p --abbrev-commit --pretty=medium'
alias -- gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign --message "--wip-- [skip ci]"'
alias -- gwt='git worktree'
alias -- gwta='git worktree add'
alias -- gwtls='git worktree list'
alias -- gwtmv='git worktree move'
alias -- gwtrm='git worktree remove'
alias -- history=omz_history
alias -- how=/Users/htlin/.dotfiles/shellscripts/how.sh
alias -- ignore='xattr -w '\''com.apple.fileprovider.ignore#P'\'' 1'
alias -- ignoredp=ignore_dropbox_folder
alias -- index='vim ~/Dropbox/Medical/index.md'
alias -- jj='cd ~/Dropbox/sprint/ && fcd && ls'
alias -- kk='cd ~/Dropbox/slowburn/ && fcd && ls'
alias -- l='ls -lah'
alias -- la='ls -lAh'
alias -- lc=lolcat
alias -- less='less -NSi -# 10'
alias -- lf=lfcd
alias -- ll='ls -lh'
alias -- lns='ln -s'
alias -- ls='lsd -1'
alias -- lsa='ls -lah'
alias -- lsgist='gh gist list --limit 30'
alias -- mac_gdrive='cd /Users/mac/Library/CloudStorage/GoogleDrive-ppoiu87@gmail.com/我的雲端硬碟'
alias -- man='colored man'
alias -- marp-serve=marp_serve
alias -- marpimg='marp --theme-set ~/Dropbox/slides/themes --html --images png'
alias -- mcpconfig='nvim ~/Library/Application\ Support/Claude/claude_desktop_config.json'
alias -- md='mkdir -p'
alias -- mkdir='mkdir -p'
alias -- more=less
alias -- mv='mv -iv'
alias -- n=pnpm
alias -- ndist='netlify deploy --prod --dir=dist'
alias -- nstart='nvim --startuptime startup.log -c exit && tail -100 startup.log'
alias -- nt=newsboat
alias -- o=open
alias -- ohmyzsh='vim ~/.oh-my-zsh'
alias -- one='tmux split-window -v -l 1'
alias -- open=open
alias -- openai='op plugin run -- openai'
alias -- opn=xdg-open
alias -- pdb-less='source-highlight     -f esc --lang-def=pdb.lang     --outlang-def=bioSyntax-vcf.outlang --style-file=pdb.style   | less'
alias -- pip=pip3
alias -- pipx='uv tool'
alias -- pom='sh pom.sh'
alias -- pptxpdf='sh pptx_to_pdf.sh'
alias -- print7f='lp -d _172_21_75_1'
alias -- pt=patients
alias -- pyinbin='pyinstaller --onedir --distpath ~/bin'
alias -- python=python3
alias -- rain='curl wttr.in/Taipei'
alias -- ranger='joshuto --output-file /tmp/joshutodir; LASTDIR=`cat /tmp/joshutodir`; cd "$LASTDIR"'
alias -- rd=rmdir
alias -- re=reload
alias -- rec='asciinema rec'
alias -- reload='exec '\''/bin/zsh'\'
alias -- rip='rip -i'
alias -- ripnetlify='rip ./.netlify'
alias -- rl='ls ~/.Trash/files'
alias -- rm='rm -i'
alias -- rn=recent_note
alias -- rsync_progress='rsync --archive --acls --xattrs --hard-links --verbose --progress'
alias -- run-help=man
alias -- sam-less='source-highlight     -f esc --lang-def=sam.lang     --outlang-def=bioSyntax.outlang     --style-file=sam.style   | less'
alias -- seetrash='ls ~/.Trash/files'
alias -- ses='sesh connect $(sesh list | fzf)'
alias -- sli=make_exec_and_slide
alias -- sn=simplenote
alias -- snippets='vim ~/.dotfiles/neovim/vscode_snippets/garden.json'
alias -- st=study
alias -- str=studyrg
alias -- t=todo.sh
alias -- taskmaster=task-master
alias -- temp='curl wttr.in/Taipei?format='\''%l:+%c+%t+but+it+feels+like+%f+%h\n'\'
alias -- tldr=tldr
alias -- tm=task-master
alias -- today=dia
alias -- todo='pter ~/Dropbox/todo/todo.txt'
alias -- trash_restore='gio trash --restore "$(gio trash --list | fzf | cut -f 1)"'
alias -- tree='lsd --tree'
alias -- tt=taskwarrior-tui
alias -- up='ffsend upload'
alias -- uptodate='ddgr -n 5 '\''https://www.uptodate.com/'\'
alias -- ur=undelfile
alias -- uvinit='uv venv && source .venv/bin/activate'
alias -- v=nvim
alias -- vc=vimconfig
alias -- vcf-less='source-highlight     -f esc --lang-def=vcf.lang     --outlang-def=bioSyntax-vcf.outlang --style-file=vcf.style   | less'
alias -- vf=neovim_fzf
alias -- vim=nvim
alias -- vimdiff='nvim -d'
alias -- viml='nvim --listen /tmp/nvim'
alias -- vs='nvim -S'
alias -- vsauto='nvim -S .vim_auto_session.vim'
alias -- wh='command -v'
alias -- which=type
alias -- which-command=whence
alias -- win=windsurf
alias -- wpy='pyenv which python'
alias -- xdg-open=open
alias -- xo=xdg-open
alias -- ymd='date +%F'
alias -- yt-mp4='yt-dlp --merge-output-format mp4'
alias -- zshconfig='vim ~/.zshrc'
alias -- ztop=zenith
# Check for rg availability
if ! command -v rg >/dev/null 2>&1; then
  alias rg='/opt/homebrew/Cellar/ripgrep/14.1.1/bin/rg'
fi
export PATH='/Users/htlin/.atuin/bin:/Users/htlin/.codeium/windsurf/bin:/opt/homebrew/bin:/opt/homebrew/sbin:Users/htlin/edirect:/Users/htlin/.yarn/bin:/Users/htlin/.config/yarn/global/node_modules/.bin:/usr/local/sbin:/Users/htlin/Dropbox/scripts:/Users/htlin/pyscripts:/Users/htlin/.dotfiles/shellscripts:/Users/htlin/bin:/usr/bin/python3:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/opt/X11/bin:/Library/TeX/texbin:/usr/local/share/dotnet:~/.dotnet/tools:/Applications/quarto/bin:/Users/htlin/Library/pnpm:/Users/htlin/.codeium/windsurf/bin:/Users/htlin/.cargo/bin:/Users/htlin/.orbstack/bin:/Applications/Visual Studio Code.app/Contents/Resources/app/bin:/Applications/WezTerm.app/Contents/MacOS:/Users/htlin/.spicetify:/Users/htlin/.local/bin:/opt/homebrew/opt/fzf/bin'
