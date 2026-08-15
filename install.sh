#!/usr/bin/env bash
#
# install.sh — unattended entry point, dispatches to the per-OS installer.
#
#   macOS → start/bootstrap       (Homebrew, oh-my-zsh, symlinks, macOS deps)
#   Linux → start/setup_linux.sh  (apt packages, oh-my-zsh, TPM, symlinks)
#
# This lives at the repo root on purpose: GitHub Codespaces' dotfiles feature
# only auto-runs an installer named install.sh / install / bootstrap[.sh] /
# setup[.sh] (or script/{bootstrap,install,setup}) at the root. Everything
# under start/ is invisible to it, so a new Codespace would otherwise clone
# this repo and do nothing useful with it.
#
# Safe to run by hand too. Always unattended: link conflicts are backed up
# rather than prompted for.
#
# Bash 3.2 compatible — see CLAUDE.md.

set -e

cd "$(dirname "$0")"
DOTFILES_ROOT=$(pwd -P)

export DOTFILES_NONINTERACTIVE=1
export DOTFILES_ON_CONFLICT="${DOTFILES_ON_CONFLICT:-backup}"

# sudo_n — true when sudo can run without prompting for a password.
sudo_n() { command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; }

case "$(uname -s)" in
  Darwin)
    exec "$DOTFILES_ROOT/start/bootstrap" -y
    ;;

  Linux)
    # setup_linux.sh ends with `chsh`, which asks for a password no unattended
    # run can answer — and its `set -e` would abort the remaining steps. So
    # settle the login shell here via passwordless sudo (Codespaces, most CI),
    # then pass SHELL through so that step sees the job as already done.
    if ! command -v zsh >/dev/null 2>&1 && sudo_n; then
      sudo apt-get update -qq
      sudo apt-get install -y -qq zsh
    fi

    zsh_path=$(command -v zsh || true)
    if [ -n "$zsh_path" ]; then
      current_shell=$(getent passwd "$(id -un)" | cut -d: -f7)
      if [ "$current_shell" != "$zsh_path" ]; then
        if sudo_n; then
          sudo chsh -s "$zsh_path" "$(id -un)" ||
            echo "install.sh: could not set zsh as the login shell; continuing" >&2
        else
          echo "install.sh: no passwordless sudo — run 'chsh -s $zsh_path' yourself" >&2
        fi
      fi
      SHELL=$zsh_path
      export SHELL
    fi

    exec "$DOTFILES_ROOT/start/setup_linux.sh"
    ;;

  *)
    echo "install.sh: unsupported OS '$(uname -s)'" >&2
    exit 1
    ;;
esac
