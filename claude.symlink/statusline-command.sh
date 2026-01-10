#!/bin/bash

# Claude Code statusline script with color support
# Format: {model} | {GitHub} | {dir} | {5h usage}({reset time}) | {weekly usage} | {context usage}
# Colors: green (normal) -> yellow (60%) -> orange (75%) -> red (90%)

# ANSI color codes
GREEN='\033[32m'
LIGHT_GREEN='\033[38;5;119m'
YELLOW='\033[33m'
ORANGE='\033[38;5;208m'
RED='\033[31m'
BLUE='\033[34m'
LIGHT_BLUE='\033[38;5;117m'
CLAUDE_ORANGE='\033[38;5;209m'
RESET='\033[0m'
DIM='\033[2m'

# Background colors with contrasting text (bold, pure black)
BG_GREEN='\033[1;38;5;0;42m'
BG_YELLOW='\033[1;38;5;0;43m'
BG_ORANGE='\033[1;38;5;0;48;5;208m'
BG_RED='\033[1;97;41m'

# Static background colors (bold, pure black)
BG_CLAUDE_ORANGE='\033[1;38;5;0;48;5;209m'
BG_FOLDER='\033[1;38;5;0;47m'
BG_LIGHT_BLUE='\033[1;38;5;0;48;5;117m'
BG_LIGHT_GREEN='\033[1;38;5;0;48;5;119m'
BG_TIME='\033[1;97;48;5;240m'

# Foreground colors for round symbols
FG_CLAUDE_ORANGE='\033[38;5;209m'
FG_FOLDER='\033[37m'
FG_LIGHT_BLUE='\033[38;5;117m'
FG_LIGHT_GREEN='\033[38;5;119m'
FG_TIME='\033[38;5;240m'
FG_GREEN='\033[32m'
FG_YELLOW='\033[33m'
FG_ORANGE='\033[38;5;208m'
FG_RED='\033[31m'

# Nerd Font icons (with trailing space) - using larger/filled variants
ICON_MODEL=$'\ue20f '
ICON_FOLDER=$'\uf07b '
ICON_CONTEXT=$'\U000f035c '
ICON_USAGE=$'\uef0c '
ICON_WEEKLY=$'\U000f00ed '
ICON_TIME=$'\U000f0954 '
ICON_SESSION=$'\U000f0b77 '
ICON_COST=$'\U000f01e0 '

# Powerline round symbols
ROUND_LEFT=$'\ue0b6'
ROUND_RIGHT=$'\ue0b4'

# Color function based on percentage (returns inverted bg color)
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

# Foreground color for round symbols
get_fg_color() {
    local pct=$1
    if [ "$pct" -ge 90 ]; then
        echo -e "$FG_RED"
    elif [ "$pct" -ge 75 ]; then
        echo -e "$FG_ORANGE"
    elif [ "$pct" -ge 60 ]; then
        echo -e "$FG_YELLOW"
    else
        echo -e "$FG_GREEN"
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
    weekly_reset=$(echo "$usage_data" | jq -r '.seven_day.resets_at // empty')

    # Calculate time left until reset
    if [ -n "$five_hour_reset" ] && [ "$five_hour_reset" != "null" ]; then
        # Use Python to calculate time remaining
        time_left=$(python3 -c "
from datetime import datetime, timezone
try:
    ts = '$five_hour_reset'
    # Parse ISO 8601 with timezone
    if '+' in ts:
        reset_dt = datetime.fromisoformat(ts)
    else:
        reset_dt = datetime.fromisoformat(ts.replace('Z', '+00:00'))
    # Get current time with timezone
    now = datetime.now(timezone.utc)
    # Calculate difference
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
    # Fallback if API fails
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
five_hour_bg=$(get_bg_color $five_hour_pct)
five_hour_fg=$(get_fg_color $five_hour_pct)
weekly_bg=$(get_bg_color $weekly_pct)
weekly_fg=$(get_fg_color $weekly_pct)
context_bg=$(get_bg_color $context_pct)
context_fg=$(get_fg_color $context_pct)

# Session time tracking
SESSION_FILE="/tmp/claude_session_start_$$"
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

# Output the formatted statusline with colors and round corners
printf "${FG_CLAUDE_ORANGE}${ROUND_LEFT}${BG_CLAUDE_ORANGE}${ICON_MODEL}%s${RESET}${FG_CLAUDE_ORANGE}${ROUND_RIGHT}${RESET} " \
    "$model"
printf "${FG_FOLDER}${ROUND_LEFT}${BG_FOLDER}${ICON_FOLDER}%s${RESET}${FG_FOLDER}${ROUND_RIGHT}${RESET} " \
    "$dir"
printf "${FG_LIGHT_BLUE}${ROUND_LEFT}${BG_LIGHT_BLUE}${ICON_SESSION}%s${RESET}${FG_LIGHT_BLUE}${ROUND_RIGHT}${RESET} " \
    "$session_display_tokens"
printf "${FG_LIGHT_GREEN}${ROUND_LEFT}${BG_LIGHT_GREEN}%s${RESET}${FG_LIGHT_GREEN}${ROUND_RIGHT}${RESET} " \
    "$session_cost_display"
printf "%b${ROUND_LEFT}%b${ICON_USAGE}%s (%s)${RESET}%b${ROUND_RIGHT}${RESET} " \
    "$five_hour_fg" "$five_hour_bg" "$five_hour_display" "$time_left" "$five_hour_fg"
printf "%b${ROUND_LEFT}%b${ICON_WEEKLY}%s${RESET}%b${ROUND_RIGHT}${RESET} " \
    "$weekly_fg" "$weekly_bg" "$weekly_display" "$weekly_fg"
printf "%b${ROUND_LEFT}%b${ICON_CONTEXT}%s%%${RESET}%b${ROUND_RIGHT}${RESET} " \
    "$context_fg" "$context_bg" "$context_pct" "$context_fg"
printf "${FG_TIME}${ROUND_LEFT}${BG_TIME}${ICON_TIME}%s${RESET}${FG_TIME}${ROUND_RIGHT}${RESET}\n" \
    "$session_display"

# Alternate between dad joke and quote based on even/odd minute
if [ $(($(date +%M) % 2)) -eq 0 ]; then
    # Even minute: show dad joke
    dad_joke=$(curl -s --connect-timeout 2 --max-time 3 -H "Accept: text/plain" "https://icanhazdadjoke.com/" 2>/dev/null)
    if [ -n "$dad_joke" ]; then
        printf "${DIM}%s${RESET}" "$dad_joke"
    else
        printf "${DIM}Keep coding and stay curious!${RESET}"
    fi
else
    # Odd minute: show quote
    quote_data=$(curl -s --connect-timeout 2 --max-time 3 "https://zenquotes.io/api/random" 2>/dev/null)
    if [ -n "$quote_data" ] && [ "$quote_data" != "[]" ]; then
        quote_text=$(echo "$quote_data" | jq -r '.[0].q // empty' 2>/dev/null)
        quote_author=$(echo "$quote_data" | jq -r '.[0].a // empty' 2>/dev/null)
        if [ -n "$quote_text" ] && [ "$quote_text" != "null" ]; then
            printf "${DIM}\"%s\" — %s${RESET}" "$quote_text" "$quote_author"
        else
            printf "${DIM}\"Code is poetry.\" — WordPress${RESET}"
        fi
    else
        printf "${DIM}\"Code is poetry.\" — WordPress${RESET}"
    fi
fi
