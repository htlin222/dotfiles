#!/usr/bin/env bash
#
# ui.sh — shared TUI helpers for the start/ scripts.
# Source this file; don't execute it. Bash 3.2 compatible (stock macOS
# bash on a fresh machine, before Homebrew installs a newer one).
#
# Degrades gracefully: colors off for non-tty / NO_COLOR / TERM=dumb,
# ASCII glyphs for non-UTF-8 locales, no spinner when output is piped.

UI_START_TIME=$(date +%s)

# ---------------------------------------------------------------- caps
UI_TTY=false
[ -t 1 ] && UI_TTY=true

UI_COLOR=false
if $UI_TTY && [ -z "${NO_COLOR:-}" ] && [ "${TERM:-dumb}" != "dumb" ]; then
  UI_COLOR=true
fi

UI_UNICODE=false
case "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" in
  *[Uu][Tt][Ff]-8* | *[Uu][Tt][Ff]8*) UI_UNICODE=true ;;
esac

if $UI_COLOR; then
  C_RESET=$'\033[0m' C_BOLD=$'\033[1m' C_DIM=$'\033[2m'
  C_RED=$'\033[31m' C_GREEN=$'\033[32m' C_YELLOW=$'\033[33m'
  C_BLUE=$'\033[34m' C_CYAN=$'\033[36m'
  UI_CLEAR=$'\r\033[2K'
else
  C_RESET='' C_BOLD='' C_DIM='' C_RED='' C_GREEN='' C_YELLOW=''
  C_BLUE='' C_CYAN=''
  UI_CLEAR=''
fi

# shellcheck disable=SC2034  # glyphs are consumed by sourcing scripts
if $UI_UNICODE; then
  I_OK='✓' I_FAIL='✗' I_WARN='!' I_ASK='?' I_STEP='▸' I_DOT='·'
  UI_SPIN_FRAMES=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
  B_TL='╭' B_TR='╮' B_BL='╰' B_BR='╯' B_H='─' B_V='│'
else
  I_OK='+' I_FAIL='x' I_WARN='!' I_ASK='?' I_STEP='>' I_DOT='-'
  UI_SPIN_FRAMES=('|' '/' '-' '\')
  B_TL='+' B_TR='+' B_BL='+' B_BR='+' B_H='-' B_V='|'
fi

# The spinner hides the cursor; make sure it comes back no matter how
# the script exits.
$UI_TTY && trap 'printf "\033[?25h"' EXIT

# ---------------------------------------------------------------- text
ui_repeat() { # char count
  local out='' i=0
  while [ "$i" -lt "$2" ]; do
    out="$out$1"
    i=$((i + 1))
  done
  printf '%s' "$out"
}

# ---------------------------------------------------------------- box
UI_BOX_W=52 # inner width

ui_banner_row() { # text [style]
  local text=$1 max=$((UI_BOX_W - 2)) pad
  if [ "${#text}" -gt "$max" ]; then
    text="…${text:$((${#text} - max + 1))}" # keep the tail (paths)
  fi
  # pad by character count — printf %-*s pads by bytes, which breaks
  # alignment for multibyte text
  pad=$((max - ${#text}))
  [ "$pad" -lt 0 ] && pad=0
  printf '%s%s%s %s%s%s%s %s%s%s\n' \
    "$C_CYAN" "$B_V" "$C_RESET" \
    "${2:-}" "$text" "$(ui_repeat ' ' "$pad")" "$C_RESET" \
    "$C_CYAN" "$B_V" "$C_RESET"
}

ui_banner() { # title [subtitle]
  local line
  line=$(ui_repeat "$B_H" "$UI_BOX_W")
  printf '\n%s%s%s%s%s\n' "$C_CYAN" "$B_TL" "$line" "$B_TR" "$C_RESET"
  ui_banner_row "$1" "$C_BOLD"
  [ -n "${2:-}" ] && ui_banner_row "$2" "$C_DIM"
  printf '%s%s%s%s%s\n' "$C_CYAN" "$B_BL" "$line" "$B_BR" "$C_RESET"
}

# ---------------------------------------------------------------- steps
UI_STEP=0
UI_STEP_TOTAL=0

ui_steps_total() { UI_STEP_TOTAL=$1; }

ui_step() { # title
  UI_STEP=$((UI_STEP + 1))
  printf '\n%s%s%s ' "$C_BLUE$C_BOLD" "$I_STEP" "$C_RESET"
  if [ "$UI_STEP_TOTAL" -gt 0 ]; then
    printf '%s[%d/%d]%s ' "$C_DIM" "$UI_STEP" "$UI_STEP_TOTAL" "$C_RESET"
  fi
  printf '%s%s%s\n' "$C_BOLD" "$1" "$C_RESET"
}

# ---------------------------------------------------------------- lines
ui_ok()   { printf '%s  %s%s%s %b\n' "$UI_CLEAR" "$C_GREEN" "$I_OK" "$C_RESET" "$1"; }
ui_info() { printf '%s  %s%s%s %b\n' "$UI_CLEAR" "$C_BLUE" "$I_DOT" "$C_RESET" "$1"; }
ui_warn() { printf '%s  %s%s%s %b\n' "$UI_CLEAR" "$C_YELLOW" "$I_WARN" "$C_RESET" "$1"; }
ui_err()  { printf '%s  %s%s%s %b\n' "$UI_CLEAR" "$C_RED" "$I_FAIL" "$C_RESET" "$1"; }

ui_fail() { # message — print and abort
  ui_err "$1"
  echo ''
  exit 1
}

# ---------------------------------------------------------------- run
# ui_run LABEL CMD [ARGS…] — run CMD with a spinner next to LABEL.
# Output is captured; on failure the last 15 lines are shown indented.
# Returns CMD's exit code (combine with `|| true` for optional steps).
ui_run() {
  local label=$1
  shift
  local out rc=0
  out=$(mktemp "${TMPDIR:-/tmp}/ui_run.XXXXXX")

  if $UI_COLOR; then
    printf '\033[?25l'
    "$@" >"$out" 2>&1 &
    local pid=$! i=0 n=${#UI_SPIN_FRAMES[@]}
    while kill -0 "$pid" 2>/dev/null; do
      printf '\r\033[2K  %s%s%s %s' \
        "$C_CYAN" "${UI_SPIN_FRAMES[$((i % n))]}" "$C_RESET" "$label"
      i=$((i + 1))
      sleep 0.1
    done
    wait "$pid" || rc=$?
    printf '\033[?25h'
  else
    "$@" >"$out" 2>&1 || rc=$?
  fi

  if [ "$rc" -eq 0 ]; then
    ui_ok "$label"
  else
    ui_err "$label ${C_DIM}(exit $rc)${C_RESET}"
    local l
    while IFS= read -r l; do
      printf '      %s%s%s\n' "$C_DIM" "$l" "$C_RESET"
    done < <(tail -n 15 "$out")
  fi
  rm -f "$out"
  return "$rc"
}

# ---------------------------------------------------------------- done
ui_done() { # [message]
  local secs=$(($(date +%s) - UI_START_TIME))
  printf '\n%s%s %s%s %s(%ss)%s\n\n' \
    "$C_GREEN$C_BOLD" "$I_OK" "${1:-Done!}" "$C_RESET" \
    "$C_DIM" "$secs" "$C_RESET"
}
