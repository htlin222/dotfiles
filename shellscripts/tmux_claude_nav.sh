#!/bin/zsh
# title: "tmux_claude_nav"
# author: Hsieh-Ting Lin
# date: "2025-02-03"
# version: 1.0.0
# description: Navigate between Claude panes with caching (Shift+Up/Down)
# Usage: tmux_claude_nav.sh [next|prev|refresh]

CACHE_DIR="/tmp/tmux_claude_cache"
CACHE_TTL=10  # seconds before refresh

session=$(tmux display-message -p '#S')
cache_file="$CACHE_DIR/${session}_panes"
index_file="$CACHE_DIR/${session}_index"

mkdir -p "$CACHE_DIR"

refresh_cache() {
    typeset -A claude_parents valid_pids

    while read -r ppid pid comm; do
        [[ "$comm" == *[Cc]laude* ]] && claude_parents[$ppid]=1
    done < <(ps -eo ppid=,pid=,comm= 2>/dev/null)

    for ppid in ${(k)claude_parents}; do
        valid_pids[$ppid]=1
        grandparent=$(ps -o ppid= -p $ppid 2>/dev/null | tr -d ' ')
        [[ -n "$grandparent" ]] && valid_pids[$grandparent]=1
    done

    local panes=()
    while IFS='|' read -r pane_pid pane_id rest; do
        [[ -n "${valid_pids[$pane_pid]}" ]] && panes+=("$pane_id")
    done < <(tmux list-panes -s -t "$session" -F '#{pane_pid}|#{window_index}:#{pane_index}')

    printf '%s\n' "${panes[@]}" > "$cache_file"

    # Reset index if current pane not in list
    local current=$(tmux display-message -p '#{window_index}:#{pane_index}')
    local idx=0
    for i in {1..${#panes[@]}}; do
        [[ "${panes[$i]}" == "$current" ]] && { idx=$i; break; }
    done
    echo "$idx" > "$index_file"
}

needs_refresh() {
    [[ ! -f "$cache_file" ]] && return 0
    local age=$(( $(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || echo 0) ))
    (( age > CACHE_TTL )) && return 0
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

    # Get target pane path before switching
    local pane_path=$(tmux display-message -p -t "$session:$win.$pane" '#{pane_current_path}')
    local dir_name="${pane_path:t}"

    # Build progress indicator: □■□□□
    local progress=""
    for ((i=1; i<=count; i++)); do
        if (( i == idx )); then
            progress+="■"
        else
            progress+="□"
        fi
    done

    # Show message FIRST, then switch (avoids flash)
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
