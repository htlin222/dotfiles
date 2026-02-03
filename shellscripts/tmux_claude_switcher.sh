#!/bin/zsh
# title: "tmux_claude_switcher"
# author: Hsieh-Ting Lin
# date: "2025-02-03"
# version: 1.3.0
# description: Fast float menu to list and switch to panes running claude

session=$(tmux display-message -p '#S')

# Get all claude process PIDs and their parent PIDs in one call
typeset -A claude_parents
while read -r ppid pid comm; do
    [[ "$comm" == *[Cc]laude* ]] && claude_parents[$ppid]=1
done < <(ps -eo ppid=,pid=,comm= 2>/dev/null)

# Also check grandparent level - get parent PIDs of claude parents
typeset -A valid_pids
for ppid in ${(k)claude_parents}; do
    valid_pids[$ppid]=1
    # Get parent of this ppid
    grandparent=$(ps -o ppid= -p $ppid 2>/dev/null | tr -d ' ')
    [[ -n "$grandparent" ]] && valid_pids[$grandparent]=1
done

# Get panes and filter
claude_panes=""
while IFS='|' read -r pane_pid pane_id window_name pane_path; do
    if [[ -n "${valid_pids[$pane_pid]}" ]]; then
        claude_panes+="$pane_id | $window_name | ${pane_path:t}"$'\n'
    fi
done < <(tmux list-panes -s -t "$session" -F '#{pane_pid}|#{window_index}:#{pane_index}|#{window_name}|#{pane_current_path}')

claude_panes="${claude_panes%$'\n'}"

if [[ -z "$claude_panes" ]]; then
    tmux display-message "No Claude panes in '$session'"
    exit 0
fi

pane_count=$(echo "$claude_panes" | wc -l | tr -d ' ')

selected=$(echo "$claude_panes" | fzf \
    --header="🤖 Claude [$pane_count] in '$session'" \
    --header-first \
    --border=rounded \
    --prompt="> " \
    --height=100% \
    --layout=reverse \
    --preview-window=hidden)

if [[ -n "$selected" ]]; then
    target=$(echo "$selected" | cut -d'|' -f1 | tr -d ' ')
    win="${target%%:*}"
    pane="${target##*:}"
    tmux select-window -t "$session:$win"
    tmux select-pane -t "$session:$win.$pane"
fi
