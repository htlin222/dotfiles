#!/bin/zsh -f
# title: "tmux_claude_switcher"
# version: 3.4.0 - active always fresh, inactive cached
# description: Claude pane switcher - active panes fresh, inactive sessions cached

session=$(tmux display-message -p '#S')
CLAUDE_DIR="$HOME/.claude/projects"
CACHE_DIR="/tmp/tmux_claude_cache"
ACTIVE_CACHE="$CACHE_DIR/${session}_active_v1"
INACTIVE_CACHE="$CACHE_DIR/${session}_inactive_v1"
TOPIC_CACHE="$CACHE_DIR/topics_v4"
ACTIVE_TTL=10
INACTIVE_TTL=30

mkdir -p "$CACHE_DIR"

# Colors
C_CYAN=$'\033[36m'
C_YELLOW=$'\033[33m'
C_MAGENTA=$'\033[35m'
C_GREEN=$'\033[32m'
C_DIM=$'\033[2m'
C_RESET=$'\033[0m'

# Get topic and branch from JSONL (cached)
get_info() {
    local jsonl_file="$1"
    local session_id="${jsonl_file:t:r}"

    if [[ -f "$TOPIC_CACHE" ]]; then
        local cached=$(grep "^${session_id}	" "$TOPIC_CACHE" 2>/dev/null | cut -f2-)
        [[ -n "$cached" ]] && { echo "$cached"; return; }
    fi

    local line=$(grep '"type":"user"' "$jsonl_file" 2>/dev/null | head -1)
    [[ -z "$line" ]] && return

    local topic=$(echo "$line" | grep -o '"content":"[^"]*"' | head -1 | cut -d'"' -f4)
    local branch=$(echo "$line" | grep -o '"gitBranch":"[^"]*"' | cut -d'"' -f4)
    local cwd=$(echo "$line" | grep -o '"cwd":"[^"]*"' | cut -d'"' -f4)

    [[ "$topic" == "<"* ]] && return

    [[ -n "$topic" ]] && echo "${session_id}	${topic}	${branch}	${cwd}" >> "$TOPIC_CACHE"
    echo "${topic}	${branch}	${cwd}"
}

# === ACTIVE PANES (10s cache) ===
typeset -A active_cwds
typeset -a active_items
max_id=0 max_dir=0 max_branch=0

use_active_cache=0
if [[ -f "$ACTIVE_CACHE" ]]; then
    mtime=$(stat -c %Y "$ACTIVE_CACHE" 2>/dev/null || stat -f %m "$ACTIVE_CACHE" 2>/dev/null || echo 0)
    (( $(date +%s) - mtime <= ACTIVE_TTL )) && use_active_cache=1
fi

if (( use_active_cache )); then
    while IFS= read -r line; do
        active_items+=("$line")
        IFS='|' read -r id dir branch topic cwd <<< "$line"
        active_cwds[$cwd]=1
        (( ${#id} > max_id )) && max_id=${#id}
        (( ${#dir} > max_dir )) && max_dir=${#dir}
        (( ${#branch} > max_branch )) && max_branch=${#branch}
    done < "$ACTIVE_CACHE"
else
    typeset -A claude_pids
    while read -r pid; do
        ppid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
        [[ -n "$ppid" ]] && claude_pids[$ppid]=1
        gppid=$(ps -o ppid= -p "$ppid" 2>/dev/null | tr -d ' ')
        [[ -n "$gppid" ]] && claude_pids[$gppid]=1
    done < <(pgrep -f '[c]laude' 2>/dev/null)

    cache_content=""
    while IFS='|' read -r pane_pid pane_id pane_path; do
        if [[ -n "${claude_pids[$pane_pid]}" ]]; then
            active_cwds[$pane_path]=1
            dir="${pane_path:t}"

            project_dir="${pane_path//\//-}"
            session_dir="$CLAUDE_DIR/$project_dir"
            latest=$(/bin/ls -t "$session_dir"/*.jsonl 2>/dev/null | head -1)
            topic="" branch=""
            if [[ -n "$latest" ]]; then
                info=$(get_info "$latest")
                topic=$(echo "$info" | cut -f1)
                branch=$(echo "$info" | cut -f2)
            fi

            item="${pane_id}|${dir}|${branch}|${topic}|${pane_path}"
            active_items+=("$item")
            cache_content+="$item"$'\n'

            (( ${#pane_id} > max_id )) && max_id=${#pane_id}
            (( ${#dir} > max_dir )) && max_dir=${#dir}
            (( ${#branch} > max_branch )) && max_branch=${#branch}
        fi
    done < <(tmux list-panes -s -t "$session" -F '#{pane_pid}|#{window_index}:#{pane_index}|#{pane_current_path}')

    echo -n "$cache_content" > "$ACTIVE_CACHE"
fi

active_count=${#active_items[@]}

# === INACTIVE SESSIONS (cached) ===
typeset -a inactive_items
inactive_count=0

use_inactive_cache=0
if [[ -f "$INACTIVE_CACHE" ]]; then
    mtime=$(stat -c %Y "$INACTIVE_CACHE" 2>/dev/null || stat -f %m "$INACTIVE_CACHE" 2>/dev/null || echo 0)
    (( $(date +%s) - mtime <= INACTIVE_TTL )) && use_inactive_cache=1
fi

if (( use_inactive_cache )); then
    while IFS= read -r line; do
        # Format: short_id|dir|branch|topic|session_id|cwd
        inactive_items+=("$line")
        short_id=$(echo "$line" | cut -d'|' -f1)
        dir=$(echo "$line" | cut -d'|' -f2)
        branch=$(echo "$line" | cut -d'|' -f3)
        cwd=$(echo "$line" | cut -d'|' -f6)

        # Skip if now active
        [[ -n "${active_cwds[$cwd]}" ]] && continue

        (( ${#short_id} > max_id )) && max_id=${#short_id}
        (( ${#dir} > max_dir )) && max_dir=${#dir}
        (( ${#branch} > max_branch )) && max_branch=${#branch}
        ((inactive_count++))
    done < "$INACTIVE_CACHE"
else
    # Rebuild inactive cache
    cache_content=""
    for project_dir in "$CLAUDE_DIR"/*(/Nom[1,15]); do
        (( inactive_count >= 15 )) && break
        latest=$(/bin/ls -t "$project_dir"/*.jsonl 2>/dev/null | head -1)
        [[ -z "$latest" ]] && continue

        info=$(get_info "$latest")
        [[ -z "$info" ]] && continue

        topic=$(echo "$info" | cut -f1)
        branch=$(echo "$info" | cut -f2)
        cwd=$(echo "$info" | cut -f3)

        [[ -n "${active_cwds[$cwd]}" ]] && continue

        # Skip if directory doesn't exist on this machine
        [[ ! -d "$cwd" ]] && continue

        session_id="${latest:t:r}"
        dir="${cwd:t}"
        short_id="${session_id:0:8}"

        item="${short_id}|${dir}|${branch}|${topic}|${session_id}|${cwd}"
        inactive_items+=("$item")
        cache_content+="$item"$'\n'

        (( ${#short_id} > max_id )) && max_id=${#short_id}
        (( ${#dir} > max_dir )) && max_dir=${#dir}
        (( ${#branch} > max_branch )) && max_branch=${#branch}
        ((inactive_count++))
    done
    # Save cache
    echo -n "$cache_content" > "$INACTIVE_CACHE"
fi

# === BUILD OUTPUT ===
output=""

# Active panes
for item in "${active_items[@]}"; do
    IFS='|' read -r id dir branch topic cwd <<< "$item"

    line="${C_GREEN}●${C_RESET} "
    line+="${C_CYAN}$(printf "%-${max_id}s" "$id")${C_RESET} "
    line+="${C_YELLOW}$(printf "%-${max_dir}s" "$dir")${C_RESET}"

    if (( max_branch > 0 )); then
        if [[ -n "$branch" ]]; then
            line+=" ${C_MAGENTA}$(printf "%-${max_branch}s" "$branch")${C_RESET}"
        else
            line+=" $(printf "%-${max_branch}s" "")"
        fi
    fi

    [[ -n "$topic" ]] && line+=" ${C_DIM}${topic}${C_RESET}"
    output+="$line"$'\n'
done

# Separator
if (( active_count > 0 && inactive_count > 0 )); then
    output+="${C_DIM}──── inactive ────${C_RESET}"$'\n'
fi

# Inactive sessions
for item in "${inactive_items[@]}"; do
    IFS='|' read -r short_id dir branch topic session_id cwd <<< "$item"

    # Skip if now active
    [[ -n "${active_cwds[$cwd]}" ]] && continue

    line="${C_DIM}○${C_RESET} "
    line+="${C_CYAN}$(printf "%-${max_id}s" "$short_id")${C_RESET} "
    line+="${C_YELLOW}$(printf "%-${max_dir}s" "$dir")${C_RESET}"

    if (( max_branch > 0 )); then
        if [[ -n "$branch" ]]; then
            line+=" ${C_MAGENTA}$(printf "%-${max_branch}s" "$branch")${C_RESET}"
        else
            line+=" $(printf "%-${max_branch}s" "")"
        fi
    fi

    [[ -n "$topic" ]] && line+=" ${C_DIM}${topic}${C_RESET}"
    line+="	${session_id}	${cwd}"
    output+="$line"$'\n'
done

output="${output%$'\n'}"

if [[ -z "$output" ]]; then
    tmux display-message "No Claude sessions"
    exit 0
fi

selected=$(echo "$output" | fzf \
    --ansi \
    --no-info \
    --header="Claude [${active_count} active, ${inactive_count} inactive]" \
    --header-first \
    --border=none \
    --prompt="> " \
    --height=100% \
    --layout=reverse \
    --preview-window=hidden \
    --with-nth=1 \
    --delimiter=$'\t')

if [[ -n "$selected" ]]; then
    [[ "$selected" == *"inactive"* ]] && exit 0

    clean=$(echo "$selected" | sed 's/\x1b\[[0-9;]*m//g')

    if [[ "$clean" == ●* ]]; then
        target=$(echo "$clean" | awk '{print $2}')
        win="${target%%:*}"
        pane="${target##*:}"
        tmux select-window -t "$session:$win"
        tmux select-pane -t "$session:$win.$pane"
    else
        session_id=$(echo "$selected" | cut -f2)
        cwd=$(echo "$selected" | cut -f3)
        tmux new-window -c "$cwd" -n "claude" "claude --resume $session_id --dangerously-skip-permissions"
    fi
fi
