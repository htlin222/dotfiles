#!/bin/bash
#
# Claude Code Statusline Script
# A custom statusline for Claude Code CLI with real-time usage metrics
#
# ============================================================================
# INSTALLATION
# ============================================================================
#
# 1. Download this script:
#    curl -o ~/.claude/statusline-command.sh https://gist.githubusercontent.com/YOUR_USERNAME/GIST_ID/raw/statusline-command.sh
#
# 2. Make it executable:
#    chmod +x ~/.claude/statusline-command.sh
#
# 3. Add to your Claude Code settings (~/.claude/settings.json):
#    {
#      "statusline": {
#        "enabled": true,
#        "command": "~/.claude/statusline-command.sh"
#      }
#    }
#
# 4. Restart Claude Code to see the statusline
#
# ============================================================================
# REQUIREMENTS
# ============================================================================
#
# - Nerd Font (for icons): https://www.nerdfonts.com/
# - jq (JSON processor): brew install jq / apt install jq
# - curl (for dad jokes API)
# - macOS Keychain access (for OAuth token to fetch real usage data)
#
# ============================================================================
# FEATURES
# ============================================================================
#
# - Vim mode indicator (INSERT=green, NORMAL=yellow, VISUAL=magenta)
# - Model name with icon
# - Current directory
# - Session tokens (input + output)
# - Session cost in USD
# - Burn rate (cost per hour)
# - Lines changed (+added / -removed)
# - Conversation depth (number of turns)
# - 5-hour usage % with time until reset (color-coded)
# - 7-day usage % (color-coded)
# - Context window usage % (color-coded)
# - Session duration
# - Dad joke (cached, updates every 5 minutes)
# - Git branch status with ahead/behind indicators (color-coded)
# - Git file status with colored status codes
#
# Color coding: green (<60%) -> yellow (60-74%) -> orange (75-89%) -> red (90%+)
#
# ============================================================================
# ICONS USED (Nerd Font)
# ============================================================================
#
# \ue7c5  - Vim mode
# \ue20f  - Model (Claude)
# \uf07b  - Folder
# \U000f0b77  - Session tokens
# \uf490  - Burn rate
# \uf44d  - Lines changed
# \uf075  - Conversation depth
# \uef0c  - 5-hour usage
# \U000f00ed  - Weekly usage
# \U000f035c  - Context window
# \U000f0954  - Time/clock
# \ue725  - Git branch
#
# ============================================================================

# Colors: green (normal) -> yellow (60%) -> orange (75%) -> red (90%)

# ANSI color codes
GREEN='\033[32m'
YELLOW='\033[33m'
ORANGE='\033[38;5;208m'
RED='\033[31m'
LIGHT_BLUE='\033[38;5;117m'
LIGHT_GREEN='\033[38;5;119m'
CLAUDE_ORANGE='\033[38;5;209m'
GRAY='\033[38;5;245m'
WHITE='\033[37m'
BLACK='\033[30m'
RESET='\033[0m'
DIM='\033[2m'

# Background colors for labels
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_ORANGE='\033[48;5;208m'
BG_RED='\033[41m'

# Nerd Font icons
ICON_MODEL=$'\ue20f '
ICON_FOLDER=$'\uf07b '
ICON_SEP_LEFT=$'\ue0ba'
ICON_SEP_RIGHT=$'\ue0bc'
ICON_CONTEXT=$'\U000f035c '
ICON_USAGE=$'\uef0c '
ICON_WEEKLY=$'\U000f00ed '
ICON_TIME=$'\U000f0954 '
ICON_SESSION=$'\U000f0b77 '
ICON_VIM=$'\ue7c5 '
ICON_LINES=$'\uf44d '
ICON_BURN=$'\uf490 '
ICON_DEPTH=$'\uf075 '

# Vim mode colors
CYAN='\033[36m'
MAGENTA='\033[35m'

# Color function based on percentage (foreground)
get_color() {
    local pct=$1
    if [ "$pct" -ge 90 ]; then
        echo -e "$RED"
    elif [ "$pct" -ge 75 ]; then
        echo -e "$ORANGE"
    elif [ "$pct" -ge 60 ]; then
        echo -e "$YELLOW"
    else
        echo -e "$GREEN"
    fi
}

# Background color function based on percentage
get_bg_color() {
    local pct=$1
    if [ "$pct" -ge 90 ]; then
        echo -e "$BG_RED"
    elif [ "$pct" -ge 75 ]; then
        echo -e "$BG_ORANGE"
    elif [ "$pct" -ge 60 ]; then
        echo -e "$BG_YELLOW"
    else
        echo -e "$BG_GREEN"
    fi
}

# Read JSON input from stdin
input=$(cat)

# Extract model display name
model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')

# Get session cost in USD
session_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
session_cost_display=$(printf "$%.2f" "$session_cost")

# Get vim mode
vim_mode=$(echo "$input" | jq -r '.vim.mode // "NORMAL"')
case "$vim_mode" in
    INSERT) vim_color="$GREEN" ;;
    NORMAL) vim_color="$YELLOW" ;;
    VISUAL) vim_color="$MAGENTA" ;;
    *) vim_color="$GRAY" ;;
esac

# Get lines changed
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

# Get conversation depth (count turns from transcript)
transcript_path=$(echo "$input" | jq -r '.transcript_path // ""')
if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
    # Count user messages (conversation turns)
    conv_depth=$(grep -c '"type":"user"' "$transcript_path" 2>/dev/null || echo "0")
else
    conv_depth=0
fi

# Get current directory name (not full path)
dir=$(basename "$(echo "$input" | jq -r '.workspace.current_dir // "."')")

# Fetch real usage data from Anthropic OAuth API
get_real_usage() {
    # Get OAuth token from macOS Keychain
    local creds=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
    if [ -z "$creds" ]; then
        echo ""
        return
    fi

    local token=$(echo "$creds" | jq -r '.claudeAiOauth.accessToken // empty')
    if [ -z "$token" ]; then
        echo ""
        return
    fi

    # Call the usage API
    curl -s "https://api.anthropic.com/api/oauth/usage" \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $token" \
        -H "anthropic-beta: oauth-2025-04-20" \
        2>/dev/null
}

# Get real usage data
usage_data=$(get_real_usage)

if [ -n "$usage_data" ] && [ "$usage_data" != "null" ]; then
    # Parse real usage data
    five_hour_pct=$(echo "$usage_data" | jq -r '.five_hour.utilization // 0' | cut -d. -f1)
    weekly_pct=$(echo "$usage_data" | jq -r '.seven_day.utilization // 0' | cut -d. -f1)

    # Get reset times
    five_hour_reset=$(echo "$usage_data" | jq -r '.five_hour.resets_at // empty')
    weekly_reset=$(echo "$usage_data" | jq -r '.seven_day.resets_at // empty')

    # Calculate time left until reset
    if [ -n "$five_hour_reset" ] && [ "$five_hour_reset" != "null" ]; then
        time_left=$(python3 -c "
from datetime import datetime, timezone
try:
    ts = '$five_hour_reset'
    if '+' in ts:
        reset_dt = datetime.fromisoformat(ts)
    else:
        reset_dt = datetime.fromisoformat(ts.replace('Z', '+00:00'))
    now = datetime.now(timezone.utc)
    diff = reset_dt - now
    total_seconds = int(diff.total_seconds())
    if total_seconds < 0:
        print('0m')
    elif total_seconds < 3600:
        minutes = total_seconds // 60
        print(f'{minutes}m')
    else:
        hours = total_seconds // 3600
        minutes = (total_seconds % 3600) // 60
        print(f'{hours}h{minutes:02d}m')
except:
    print('--')
" 2>/dev/null || echo "--")
    else
        time_left="--"
    fi

    # Format weekly reset date as mm/dd
    if [ -n "$weekly_reset" ] && [ "$weekly_reset" != "null" ]; then
        weekly_reset_date=$(python3 -c "
from datetime import datetime
try:
    ts = '$weekly_reset'
    if '+' in ts:
        reset_dt = datetime.fromisoformat(ts)
    else:
        reset_dt = datetime.fromisoformat(ts.replace('Z', '+00:00'))
    print(reset_dt.strftime('%m/%d'))
except:
    print('--')
" 2>/dev/null || echo "--")
    else
        weekly_reset_date="--"
    fi

    five_hour_display="${five_hour_pct}%"
    weekly_display="${weekly_pct}%"
else
    five_hour_pct=0
    weekly_pct=0
    time_left="--"
    weekly_reset_date="--"
    five_hour_display="N/A"
    weekly_display="N/A"
fi

# Calculate session tokens
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
session_tokens=$((total_input + total_output))

# Format session tokens (K suffix)
if [ $session_tokens -ge 1000000 ]; then
    session_display_tokens="$(echo "scale=1; $session_tokens / 1000000" | bc)M"
elif [ $session_tokens -ge 1000 ]; then
    session_display_tokens="$(echo "scale=1; $session_tokens / 1000" | bc)K"
else
    session_display_tokens="${session_tokens}"
fi

# Calculate current context window usage percentage
current_usage=$(echo "$input" | jq '.context_window.current_usage')
if [ "$current_usage" != "null" ]; then
    input_tokens=$(echo "$current_usage" | jq '.input_tokens // 0')
    cache_creation=$(echo "$current_usage" | jq '.cache_creation_input_tokens // 0')
    cache_read=$(echo "$current_usage" | jq '.cache_read_input_tokens // 0')
    current_total=$((input_tokens + cache_creation + cache_read))
    window_size=$(echo "$input" | jq '.context_window.context_window_size // 200000')
    context_pct=$((current_total * 100 / window_size))
else
    context_pct=0
fi

# Get colors for each metric (foreground and background)
five_hour_color=$(get_color $five_hour_pct)
five_hour_bg=$(get_bg_color $five_hour_pct)
weekly_color=$(get_color $weekly_pct)
weekly_bg=$(get_bg_color $weekly_pct)
context_color=$(get_color $context_pct)
context_bg=$(get_bg_color $context_pct)

# Session time tracking
PARENT_SESSION_FILE="/tmp/claude_session_start_$PPID"
if [ -f "$PARENT_SESSION_FILE" ]; then
    session_start=$(cat "$PARENT_SESSION_FILE")
else
    session_start=$(date +%s)
    echo "$session_start" > "$PARENT_SESSION_FILE"
fi
current_time=$(date +%s)
elapsed=$((current_time - session_start))
elapsed_min=$((elapsed / 60))
session_display=$(printf "%dm" $elapsed_min)

# Calculate burn rate (cost per hour)
if [ $elapsed_min -gt 0 ]; then
    burn_rate=$(echo "scale=2; $session_cost * 60 / $elapsed_min" | bc 2>/dev/null || echo "0")
else
    burn_rate="0"
fi

# Output the formatted statusline
# Line 1: model, folder, tokens, cost, time, burn, lines, depth, vim
printf "${CLAUDE_ORANGE}${ICON_MODEL}%s${RESET} " "$model"
printf "${WHITE}${ICON_FOLDER}%s${RESET} " "$dir"
printf "${LIGHT_BLUE}%s${RESET} " "$session_display_tokens"
printf "${LIGHT_GREEN}%s${RESET} " "$session_cost_display"
printf "${GRAY}%s${RESET} " "$session_display"
printf "${CYAN}\$%s/h${RESET} " "$burn_rate"
printf "${GREEN}+%s${RESET}${RED}-%s${RESET} " "$lines_added" "$lines_removed"
printf "${LIGHT_BLUE}${ICON_DEPTH}%s${RESET} " "$conv_depth"
printf "%b${ICON_VIM}%s${RESET}\n" "$vim_color" "$vim_mode"
# Line 2: 5h usage, weekly, context (with background-colored labels)
printf "%b${BLACK} \uf252 ${RESET}%b${ICON_SEP_RIGHT}${RESET} %b%s${RESET} ${GRAY}${ICON_TIME}%s${RESET} " "$five_hour_bg" "$five_hour_color" "$five_hour_color" "$five_hour_display" "$time_left"
printf "%b${ICON_SEP_LEFT}%b${BLACK} \U000f00f0 ${RESET}%b${ICON_SEP_RIGHT}${RESET} %b%s${RESET} ${GRAY}\U000f110b %s${RESET} " "$weekly_color" "$weekly_bg" "$weekly_color" "$weekly_color" "$weekly_display" "$weekly_reset_date"
printf "%b${ICON_SEP_LEFT}%b${BLACK} \U000f05c4 ${RESET}%b${ICON_SEP_RIGHT}${RESET} %b%s%%${RESET}\n" "$context_color" "$context_bg" "$context_color" "$context_color" "$context_pct"

# Dad joke with 5-minute cache
DAD_JOKE_CACHE="/tmp/claude_dad_joke_cache"
DAD_JOKE_LOCK="/tmp/claude_dad_joke_lock"
# Use 5-minute intervals: floor(minute/5)*5
current_5min=$(date +%Y%m%d%H)$(printf "%02d" $(($(date +%-M) / 5 * 5)))

# Check if cache exists and is from current 5-min window
if [ -f "$DAD_JOKE_CACHE" ]; then
    cached_time=$(head -1 "$DAD_JOKE_CACHE" 2>/dev/null)
    if [ "$cached_time" = "$current_5min" ]; then
        dad_joke=$(tail -n +2 "$DAD_JOKE_CACHE")
    fi
fi

# If no cached joke, fetch new one (with lock to prevent concurrent requests)
if [ -z "$dad_joke" ]; then
    if mkdir "$DAD_JOKE_LOCK" 2>/dev/null; then
        dad_joke=$(curl -s --connect-timeout 1 --max-time 2 -H "Accept: text/plain" "https://icanhazdadjoke.com/" 2>/dev/null)
        if [ -n "$dad_joke" ]; then
            echo "$current_5min" > "$DAD_JOKE_CACHE"
            echo "$dad_joke" >> "$DAD_JOKE_CACHE"
        fi
        rmdir "$DAD_JOKE_LOCK" 2>/dev/null
    else
        # Lock held, use old cached joke regardless of age
        if [ -f "$DAD_JOKE_CACHE" ]; then
            dad_joke=$(tail -n +2 "$DAD_JOKE_CACHE")
        fi
    fi
fi

# Display joke or fallback
if [ -n "$dad_joke" ]; then
    printf "${DIM}%s${RESET}" "$dad_joke"
else
    printf "${DIM}Keep coding and stay curious!${RESET}"
fi

# Git status with colored branch and status codes
git_dir=$(echo "$input" | jq -r '.workspace.current_dir // "."')

# Branch status line
ICON_BRANCH=$'\ue725 '
branch_line=$(git -C "$git_dir" status -sb 2>/dev/null | head -1)
if [ -n "$branch_line" ]; then
    printf "\n"
    # Remove ## prefix and replace with icon
    branch_line="${branch_line#\#\# }"
    # Colorize [ahead X], [behind Y], or [ahead X, behind Y]
    if [[ "$branch_line" == *"ahead"* ]] && [[ "$branch_line" == *"behind"* ]]; then
        # Both - yellow
        prefix="${branch_line%% \[*}"
        status="${branch_line##*\[}"
        status="${status%\]}"
        ahead_num=$(echo "$status" | grep -o 'ahead [0-9]*' | grep -o '[0-9]*')
        behind_num=$(echo "$status" | grep -o 'behind [0-9]*' | grep -o '[0-9]*')
        ahead_dots=$(printf '● %.0s' $(seq 1 ${ahead_num:-0}))
        behind_dots=$(printf '● %.0s' $(seq 1 ${behind_num:-0}))
        printf "${ICON_BRANCH}%s ${YELLOW}[%s]${RESET} ${GREEN}%s${RESET}${RED}%s${RESET}\n" "$prefix" "$status" "$ahead_dots" "$behind_dots"
    elif [[ "$branch_line" == *"ahead"* ]]; then
        # Ahead only - green
        prefix="${branch_line%% \[*}"
        status="${branch_line##*\[}"
        status="${status%\]}"
        ahead_num=$(echo "$status" | grep -o '[0-9]*')
        ahead_dots=$(printf '● %.0s' $(seq 1 ${ahead_num:-0}))
        printf "${ICON_BRANCH}%s ${GREEN}[%s] %s${RESET}\n" "$prefix" "$status" "$ahead_dots"
    elif [[ "$branch_line" == *"behind"* ]]; then
        # Behind only - red
        prefix="${branch_line%% \[*}"
        status="${branch_line##*\[}"
        status="${status%\]}"
        behind_num=$(echo "$status" | grep -o '[0-9]*')
        behind_dots=$(printf '● %.0s' $(seq 1 ${behind_num:-0}))
        printf "${ICON_BRANCH}%s ${RED}[%s] %s${RESET}\n" "$prefix" "$status" "$behind_dots"
    else
        # Up to date or no remote
        printf "${ICON_BRANCH}%s\n" "$branch_line"
    fi
fi

git_status=$(git -C "$git_dir" status -s 2>/dev/null | grep -v '^##' | head -5)
if [ -n "$git_status" ]; then
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            # XY format: X=index, Y=worktree
            x_char="${line:0:1}"
            y_char="${line:1:1}"
            rest="${line:2}"

            # Color X (index status)
            case "$x_char" in
                M) x_colored="${YELLOW}M${RESET}" ;;
                A) x_colored="${GREEN}A${RESET}" ;;
                D) x_colored="${RED}D${RESET}" ;;
                R) x_colored="${LIGHT_BLUE}R${RESET}" ;;
                C) x_colored="${LIGHT_BLUE}C${RESET}" ;;
                T) x_colored="${ORANGE}T${RESET}" ;;
                U) x_colored="${RED}U${RESET}" ;;
                \?) x_colored="${GRAY}?${RESET}" ;;
                !) x_colored="${DIM}!${RESET}" ;;
                *) x_colored="$x_char" ;;
            esac

            # Color Y (worktree status)
            case "$y_char" in
                M) y_colored="${YELLOW}M${RESET}" ;;
                A) y_colored="${GREEN}A${RESET}" ;;
                D) y_colored="${RED}D${RESET}" ;;
                R) y_colored="${LIGHT_BLUE}R${RESET}" ;;
                C) y_colored="${LIGHT_BLUE}C${RESET}" ;;
                T) y_colored="${ORANGE}T${RESET}" ;;
                U) y_colored="${RED}U${RESET}" ;;
                \?) y_colored="${GRAY}?${RESET}" ;;
                !) y_colored="${DIM}!${RESET}" ;;
                *) y_colored="$y_char" ;;
            esac

            printf "%b%b%s\n" "$x_colored" "$y_colored" "$rest"
        fi
    done <<< "$git_status"
fi
