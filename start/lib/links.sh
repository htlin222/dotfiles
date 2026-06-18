#!/usr/bin/env bash
#
# links.sh — shared symlink logic for the start/ scripts.
# Requires ui.sh to be sourced first, and $DOTFILES_ROOT to be set.

LINKED=0
ALREADY=0
SKIPPED=0
BACKED_UP=0
OVERWRITTEN=0

# Conflict policy, overridable by callers before invoking link_file
# (e.g. setup_linux.sh sets backup_all=true for unattended runs).
overwrite_all=false
backup_all=false
skip_all=false

# Non-interactive mode: never prompt on conflicts. Auto-enabled when
# DOTFILES_NONINTERACTIVE=1, or when there's no TTY to prompt on (piped
# output, CI, agent runs) — which also avoids a `read </dev/tty` failure
# aborting the script under `set -e`. Resolve flags with links_parse_args.
if [ "${DOTFILES_NONINTERACTIVE:-}" = 1 ] || [ "${UI_TTY:-true}" = false ]; then
  noninteractive=true
else
  noninteractive=false
fi

# Conflict policy used in non-interactive mode (non-destructive by default).
# Override with DOTFILES_ON_CONFLICT=overwrite|backup|skip or the flags.
on_conflict=${DOTFILES_ON_CONFLICT:-backup}

# links_parse_args ARGS… — parse the common flags shared by the link-aware
# entry scripts. Calls `usage` (if the caller defined one) for -h/--help.
links_parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      -y | --yes | --non-interactive | --noninteractive)
        noninteractive=true ;;
      --overwrite) noninteractive=true; on_conflict=overwrite ;;
      --backup)    noninteractive=true; on_conflict=backup ;;
      --skip)      noninteractive=true; on_conflict=skip ;;
      -h | --help)
        command -v usage >/dev/null 2>&1 && usage
        exit 0 ;;
      *) ui_warn "ignoring unknown option: ${C_BOLD}$1${C_RESET}" ;;
    esac
    shift
  done
}

ui_home() { # abbreviate $HOME to ~ for display
  case "$1" in
    "$HOME"/*) printf '~%s' "${1#"$HOME"}" ;;
    *) printf '%s' "$1" ;;
  esac
}

link_file() { # src dst
  local src=$1 dst=$2
  local overwrite='' backup='' skip='' action=''

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    # Already pointing at the right place (or literally the same file —
    # guards against symlinking the repo onto itself).
    if [ "$dst" -ef "$src" ] || [ "$(readlink "$dst" 2>/dev/null)" = "$src" ]; then
      ALREADY=$((ALREADY + 1))
      ui_info "${C_DIM}already linked $(ui_home "$dst")${C_RESET}"
      return 0
    fi

    if [ "$overwrite_all" = false ] && [ "$backup_all" = false ] && [ "$skip_all" = false ]; then
      if [ "$noninteractive" = true ]; then
        # No prompt: apply the configured default policy to every conflict.
        case "$on_conflict" in
          overwrite) overwrite_all=true ;;
          skip)      skip_all=true ;;
          *)         backup_all=true ;;
        esac
      else
        local current
        current=$(readlink "$dst" 2>/dev/null || true)
        printf '\n  %s%s%s %s%s%s exists' \
          "$C_YELLOW$C_BOLD" "$I_ASK" "$C_RESET" \
          "$C_BOLD" "$(ui_home "$dst")" "$C_RESET"
        if [ -n "$current" ]; then
          printf ' %s(currently → %s)%s' "$C_DIM" "$current" "$C_RESET"
        fi
        printf '\n    %s[s]%skip  %s[o]%sverwrite  %s[b]%sackup  %s(capital = apply to all)%s ' \
          "$C_CYAN" "$C_RESET" "$C_CYAN" "$C_RESET" "$C_CYAN" "$C_RESET" \
          "$C_DIM" "$C_RESET"
        read -r -n 1 action </dev/tty
        echo ''

        case "$action" in
          o) overwrite=true ;;
          O) overwrite_all=true ;;
          b) backup=true ;;
          B) backup_all=true ;;
          s) skip=true ;;
          S) skip_all=true ;;
          *) skip=true ;;
        esac
      fi
    fi

    overwrite=${overwrite:-$overwrite_all}
    backup=${backup:-$backup_all}
    skip=${skip:-$skip_all}

    if [ "$overwrite" = true ]; then
      rm -rf "$dst"
      OVERWRITTEN=$((OVERWRITTEN + 1))
      ui_warn "removed $(ui_home "$dst")"
    elif [ "$backup" = true ]; then
      mv "$dst" "${dst}.backup"
      BACKED_UP=$((BACKED_UP + 1))
      ui_ok "backed up $(ui_home "$dst") ${C_DIM}→ $(ui_home "$dst").backup${C_RESET}"
    elif [ "$skip" = true ]; then
      SKIPPED=$((SKIPPED + 1))
      ui_info "${C_DIM}skipped $(ui_home "$dst")${C_RESET}"
    fi
  fi

  if [ "$skip" != true ]; then
    ln -s "$src" "$dst"
    LINKED=$((LINKED + 1))
    ui_ok "$(ui_home "$dst") ${C_DIM}→ ${src#"$DOTFILES_ROOT"/}${C_RESET}"
  fi
}

install_dotfiles() { # link every *.symlink under $DOTFILES_ROOT into $HOME
  local src dst
  while IFS= read -r src; do
    dst="$HOME/.$(basename "${src%.*}")"
    link_file "$src" "$dst"
  done < <(find -H "$DOTFILES_ROOT" -maxdepth 2 -name '*.symlink' -not -path '*.git*' | sort)
}

links_summary() {
  local parts="${C_GREEN}$LINKED linked${C_RESET}"
  [ "$ALREADY" -gt 0 ] && parts="$parts ${C_DIM}$I_DOT${C_RESET} $ALREADY already linked"
  [ "$BACKED_UP" -gt 0 ] && parts="$parts ${C_DIM}$I_DOT${C_RESET} ${C_YELLOW}$BACKED_UP backed up${C_RESET}"
  [ "$OVERWRITTEN" -gt 0 ] && parts="$parts ${C_DIM}$I_DOT${C_RESET} ${C_RED}$OVERWRITTEN overwritten${C_RESET}"
  [ "$SKIPPED" -gt 0 ] && parts="$parts ${C_DIM}$I_DOT${C_RESET} $SKIPPED skipped"
  printf '\n  %b\n' "$parts"
}
