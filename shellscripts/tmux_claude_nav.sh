#!/bin/zsh -f
# tmux_claude_nav v2 - Optimized version
zmodload zsh/stat 2>/dev/null  # for zstat
# Changes:
# 1. Single ps call for all process info (no N×ps for grandparents)
# 2. Simpler parsing with awk instead of zsh loops
# 3. Combine stat+date into single zsh test

CACHE_DIR="/tmp/tmux_claude_cache"
CACHE_TTL=60

session=$(tmux display-message -p '#S')
cache_file="$CACHE_DIR/${session}_panes"
index_file="$CACHE_DIR/${session}_index"

mkdir -p "$CACHE_DIR"

refresh_cache() {
    # Single ps call: get all ppid,pid,comm in one shot
    # Then use awk to find Claude processes and their ancestors
    local valid_pids
    valid_pids=$(ps -eo ppid=,pid=,comm= 2>/dev/null | awk '
    {
        ppid=$1; pid=$2; comm=$3
        parent[pid] = ppid
        if (tolower(comm) ~ /claude/) {
            claude_parents[ppid] = 1
        }
    }
    END {
        for (p in claude_parents) {
            print p
            if (p in parent) print parent[p]  # grandparent
        }
    }' | sort -u | tr '\n' '|' | sed 's/|$//')

    # Get Claude panes in one tmux call
    tmux list-panes -s -t "$session" -F '#{pane_pid}|#{window_index}:#{pane_index}' | \
        awk -F'|' -v pids="$valid_pids" '
        BEGIN { split(pids, arr, "|"); for (i in arr) valid[arr[i]] = 1 }
        valid[$1] { print $2 }
        ' > "$cache_file"

    # Reset index
    local current=$(tmux display-message -p '#{window_index}:#{pane_index}')
    local idx=0 i=0
    while read -r line; do
        ((i++))
        [[ "$line" == "$current" ]] && idx=$i
    done < "$cache_file"
    echo "${idx:-1}" > "$index_file"
}

needs_refresh() {
    [[ ! -f "$cache_file" ]] && return 0
    # Use zsh stat module (faster than forking stat command)
    local mtime
    if (( $+functions[zstat] )) || [[ -n "${modules[zsh/stat]}" ]]; then
        zstat -A mtime +mtime "$cache_file" 2>/dev/null || return 0
    else
        # Fallback: single stat call (macOS compatible)
        mtime=$(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null) || return 0
    fi
    (( EPOCHSECONDS - mtime > CACHE_TTL )) && return 0
    return 1
}

navigate() {
    local direction=$1

    needs_refresh && refresh_cache

    [[ ! -s "$cache_file" ]] && { tmux display-message "No Claude panes"; return; }

    local -a panes=("${(@f)$(< "$cache_file")}")
    local count=${#panes[@]}

    (( count == 0 )) && { tmux display-message "No Claude panes"; return; }

    local idx=$(< "$index_file" 2>/dev/null || echo 1)

    if [[ "$direction" == "next" ]]; then
        idx=$(( (idx % count) + 1 ))
    else
        idx=$(( idx - 1 ))
        (( idx < 1 )) && idx=$count
    fi

    echo "$idx" > "$index_file"

    local target="${panes[$idx]}"
    local win="${target%%:*}"
    local pane="${target##*:}"

    # Combine display + switch
    local pane_path=$(tmux display-message -p -t "$session:$win.$pane" '#{pane_current_path}')
    local dir_name="${pane_path:t}"

    # Progress indicator
    local progress=""
    for ((i=1; i<=count; i++)); do
        (( i == idx )) && progress+="■" || progress+="□"
    done

    tmux display-message -d 1500 "#[bg=colour208,fg=colour16,bold] Claude $progress #[default] #[fg=colour51,bold]$win#[default].$pane #[fg=colour245]$dir_name#[default]"
    tmux select-window -t "$session:$win"
    tmux select-pane -t "$session:$win.$pane"
}

case "$1" in
    next)    navigate next ;;
    prev)    navigate prev ;;
    refresh) refresh_cache; tmux display-message "Claude cache refreshed" ;;
    *)       echo "Usage: $0 [next|prev|refresh]" ;;
esac
