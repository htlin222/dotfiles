#!/usr/bin/env bash

is_mac() {
  [[ "$(uname -s)" == "Darwin" ]]
}

notify() {
  local title="$1"
  local message="$2"
  if is_mac && command -v osascript >/dev/null 2>&1; then
    osascript -e "display notification \"${message}\" with title \"${title}\"" >/dev/null 2>&1
  elif command -v notify-send >/dev/null 2>&1; then
    notify-send "${title}" "${message}" >/dev/null 2>&1
  fi
}

open_cmd() {
  local args=("$@")
  if command -v open >/dev/null 2>&1; then
    open "${args[@]}"
    return $?
  fi

  # Drop macOS-only -g flag for Linux openers
  if [[ "${args[0]}" == "-g" ]]; then
    args=("${args[@]:1}")
  fi

  if command -v xdg-open >/dev/null 2>&1; then
    xdg-open "${args[@]}"
  elif command -v gio >/dev/null 2>&1; then
    gio open "${args[@]}"
  else
    echo "No open command found (open/xdg-open/gio)" >&2
    return 127
  fi
}

pbpaste_cmd() {
  if command -v pbpaste >/dev/null 2>&1; then
    pbpaste
  elif command -v wl-paste >/dev/null 2>&1; then
    wl-paste
  elif command -v xclip >/dev/null 2>&1; then
    xclip -selection clipboard -o
  elif command -v xsel >/dev/null 2>&1; then
    xsel --clipboard --output
  else
    echo "No clipboard paste command found (pbpaste/wl-paste/xclip/xsel)" >&2
    return 127
  fi
}

pbcopy_cmd() {
  if command -v pbcopy >/dev/null 2>&1; then
    pbcopy
  elif command -v wl-copy >/dev/null 2>&1; then
    wl-copy
  elif command -v xclip >/dev/null 2>&1; then
    xclip -selection clipboard
  elif command -v xsel >/dev/null 2>&1; then
    xsel --clipboard --input
  else
    echo "No clipboard copy command found (pbcopy/wl-copy/xclip/xsel)" >&2
    return 127
  fi
}
