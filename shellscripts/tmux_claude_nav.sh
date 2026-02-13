#!/bin/zsh -f
# tmux_claude_nav v3 - Robust version
zmodload zsh/stat 2>/dev/null     # for zstat
zmodload zsh/datetime 2>/dev/null  # for EPOCHSECONDS

CACHE_DIR="/tmp/tmux_claude_cache"
CACHE_TTL=60

session=$(tmux display-message -p '#S' 2>/dev/null) || exit 1
cache_file="$CACHE_DIR/${session}_panes"
index_file="$CACHE_DIR/${session}_index"

mkdir -p "$CACHE_DIR"

refresh_cache() {
    # Match only the claude CLI binary, not Claude.app desktop processes
    # ps comm= shows full path on macOS; match basename "claude" exactly
    local valid_pids
    valid_pids=$(ps -eo ppid=,pid=,comm= 2>/dev/null | awk '
    {
        ppid=$1; pid=$2; comm=$3
        parent[pid] = ppid
        # Match basename: strip path, check exact "claude" (not claude-hooks, Claude.app, etc.)
        n = split(comm, parts, "/")
        base = parts[n]
        if (base == "claude") {
            claude_parents[ppid] = 1
        }
    }
    END {
        for (p in claude_parents) {
            if (p == 0 || p == 1) continue  # skip init/launchd
            print p
            if (p in parent && parent[p] != 0 && parent[p] != 1) print parent[p]
        }
    }' | sort -u | tr '\n' '|' | sed 's/|$//')

    [[ -z "$valid_pids" ]] && { : > "$cache_file"; return; }

    # Get Claude panes in one tmux call
    tmux list-panes -s -t "$session" -F '#{pane_pid}|#{window_index}:#{pane_index}' 2>/dev/null | \
        awk -F'|' -v pids="$valid_pids" '
        BEGIN { split(pids, arr, "|"); for (i in arr) valid[arr[i]] = 1 }
        valid[$1] { print $2 }
        ' > "$cache_file"

    # Reset index to current pane position
    local current=$(tmux display-message -p '#{window_index}:#{pane_index}' 2>/dev/null)
    local idx=0 i=0
    while read -r line; do
        ((i++))
        [[ "$line" == "$current" ]] && idx=$i
    done < "$cache_file"
    echo "${idx:-1}" > "$index_file"
}

needs_refresh() {
    [[ ! -f "$cache_file" ]] && return 0
    local mtime now
    # Get mtime
    if [[ -n "${modules[zsh/stat]}" ]]; then
        zstat -A mtime +mtime "$cache_file" 2>/dev/null || return 0
    else
        mtime=$(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null) || return 0
    fi
    # Get current time (prefer EPOCHSECONDS, fallback to date)
    if [[ -n "$EPOCHSECONDS" ]]; then
        now=$EPOCHSECONDS
    else
        now=$(date +%s)
    fi
    (( now - mtime > CACHE_TTL )) && return 0
    return 1
}

# Check if a target pane actually exists
pane_exists() {
    tmux display-message -p -t "$session:$1" '#{pane_id}' &>/dev/null
}

navigate() {
    local direction=$1

    needs_refresh && refresh_cache

    [[ ! -s "$cache_file" ]] && { tmux display-message "No Claude panes"; return; }

    local -a panes=("${(@f)$(< "$cache_file")}")
    local count=${#panes[@]}

    (( count == 0 )) && { tmux display-message "No Claude panes"; return; }

    local idx=$(< "$index_file" 2>/dev/null || echo 1)
    # Clamp index to valid range (handles stale index files)
    (( idx > count )) && idx=$count
    (( idx < 1 )) && idx=1

    if [[ "$direction" == "next" ]]; then
        idx=$(( (idx % count) + 1 ))
    else
        idx=$(( idx - 1 ))
        (( idx < 1 )) && idx=$count
    fi

    local target="${panes[$idx]}"

    # Validate target exists; if stale, force refresh and retry once
    if ! pane_exists "$target"; then
        refresh_cache
        panes=("${(@f)$(< "$cache_file")}")
        count=${#panes[@]}
        (( count == 0 )) && { tmux display-message "No Claude panes"; return; }
        (( idx > count )) && idx=1
        target="${panes[$idx]}"
        if ! pane_exists "$target"; then
            tmux display-message "No Claude panes"
            return
        fi
    fi

    echo "$idx" > "$index_file"

    local win="${target%%:*}"
    local pane="${target##*:}"

    local pane_path=$(tmux display-message -p -t "$session:$win.$pane" '#{pane_current_path}' 2>/dev/null)
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
