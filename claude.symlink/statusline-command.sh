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
# - Model name with icon
# - Current directory
# - Session tokens (input + output)
# - Session cost in USD
# - 5-hour usage % with time until reset (color-coded)
# - 7-day usage % (color-coded)
# - Context window usage % (color-coded)
# - Session duration
# - Dad joke (cached, updates every minute)
# - Git branch status with ahead/behind indicators (color-coded)
# - Git file status with colored status codes
#
# Color coding: green (<60%) -> yellow (60-74%) -> orange (75-89%) -> red (90%+)
#
# ============================================================================
# ICONS USED (Nerd Font)
# ============================================================================
#
# \ue20f  - Model (Claude)
# \uf07b  - Folder
# \U000f0b77  - Session tokens
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
RESET='\033[0m'
DIM='\033[2m'

# Nerd Font icons
ICON_MODEL=$'\ue20f '
ICON_FOLDER=$'\uf07b '
ICON_CONTEXT=$'\U000f035c '
ICON_USAGE=$'\uef0c '
ICON_WEEKLY=$'\U000f00ed '
ICON_TIME=$'\U000f0954 '
ICON_SESSION=$'\U000f0b77 '

# Color function based on percentage
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

# Read JSON input from stdin
input=$(cat)

# Extract model display name
model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')

# Get session cost in USD
session_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
session_cost_display=$(printf "$%.2f" "$session_cost")

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

    five_hour_display="${five_hour_pct}%"
    weekly_display="${weekly_pct}%"
else
    five_hour_pct=0
    weekly_pct=0
    time_left="--"
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

# Get colors for each metric
five_hour_color=$(get_color $five_hour_pct)
weekly_color=$(get_color $weekly_pct)
context_color=$(get_color $context_pct)

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

# Output the formatted statusline - single line
printf "${CLAUDE_ORANGE}${ICON_MODEL}%s${RESET} " "$model"
printf "${WHITE}${ICON_FOLDER}%s${RESET} " "$dir"
printf "${LIGHT_BLUE}${ICON_SESSION}%s${RESET} " "$session_display_tokens"
printf "${LIGHT_GREEN}%s${RESET} " "$session_cost_display"
printf "%b${ICON_USAGE}%s (%s)${RESET} " "$five_hour_color" "$five_hour_display" "$time_left"
printf "%b${ICON_WEEKLY}%s${RESET} " "$weekly_color" "$weekly_display"
printf "%b${ICON_CONTEXT}%s%%${RESET} " "$context_color" "$context_pct"
printf "${GRAY}${ICON_TIME}%s${RESET}\n" "$session_display"

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
        printf "${ICON_BRANCH}%s ${YELLOW}[%s]${RESET}\n" "$prefix" "$status"
    elif [[ "$branch_line" == *"ahead"* ]]; then
        # Ahead only - green
        prefix="${branch_line%% \[*}"
        status="${branch_line##*\[}"
        status="${status%\]}"
        printf "${ICON_BRANCH}%s ${GREEN}[%s]${RESET}\n" "$prefix" "$status"
    elif [[ "$branch_line" == *"behind"* ]]; then
        # Behind only - red
        prefix="${branch_line%% \[*}"
        status="${branch_line##*\[}"
        status="${status%\]}"
        printf "${ICON_BRANCH}%s ${RED}[%s]${RESET}\n" "$prefix" "$status"
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
