#!/usr/bin/env bash
#
# Linux (Pop!_OS) setup for neovim, tmux, and zsh
#

set -e

cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd -P)

source "$DOTFILES_ROOT/start/lib/ui.sh"
source "$DOTFILES_ROOT/start/lib/links.sh"

usage() {
  cat <<'EOF'
Usage: start/setup_linux.sh [options]

Pop!_OS/apt setup: packages, oh-my-zsh + plugins, TPM, symlinks, chsh.
Always unattended — link conflicts are backed up, never prompted.

Options:
  -h, --help   Show this help

Note: `sudo apt` will prompt for your password.
EOF
}

case "${1:-}" in -h | --help) usage; exit 0 ;; esac

# Unattended runs: never prompt on conflicts, keep a .backup instead.
# shellcheck disable=SC2034  # consumed by link_file in links.sh
backup_all=true

# ============================================
# 1. Install system packages
# ============================================
install_packages() {
  ui_step "System packages"
  # Streamed (not spinnered): apt needs the sudo password prompt visible.
  sudo apt update
  sudo apt install -y \
    zsh \
    tmux \
    neovim \
    git \
    curl \
    wget \
    ripgrep \
    fd-find \
    fzf \
    bat \
    eza \
    zoxide \
    build-essential \
    unzip \
    fontconfig

  # Create fd symlink (Ubuntu/Debian names it fdfind)
  if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    mkdir -p ~/.local/bin
    ln -sf "$(which fdfind)" ~/.local/bin/fd
  fi

  ui_ok "system packages installed"
}

# ============================================
# 2. Install Oh-My-Zsh
# ============================================
install_ohmyzsh() {
  ui_step "oh-my-zsh"
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    ui_run "install oh-my-zsh" \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  else
    ui_ok "already installed"
  fi
}

# ============================================
# 3. Install Zsh plugins
# ============================================
install_zsh_plugins() {
  local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  ui_step "Zsh plugins"

  local entry name kind url dst
  for entry in \
    'powerlevel10k|themes|https://github.com/romkatv/powerlevel10k.git' \
    'zsh-autosuggestions|plugins|https://github.com/zsh-users/zsh-autosuggestions' \
    'fast-syntax-highlighting|plugins|https://github.com/zdharma-continuum/fast-syntax-highlighting.git' \
    'zsh-vi-mode|plugins|https://github.com/jeffreytse/zsh-vi-mode' \
    'fzf-tab|plugins|https://github.com/Aloxaf/fzf-tab' \
    'zsh-autopair|plugins|https://github.com/hlissner/zsh-autopair' \
    'zsh-lazyload|plugins|https://github.com/qoomon/zsh-lazyload' \
    'zsh-auto-notify|plugins|https://github.com/MichaelAquilina/zsh-auto-notify.git'; do
    name=${entry%%|*}
    kind=${entry#*|}
    kind=${kind%%|*}
    url=${entry##*|}
    dst="$ZSH_CUSTOM/$kind/$name"
    if [ -d "$dst" ]; then
      ui_info "${C_DIM}$name already installed${C_RESET}"
    else
      ui_run "$name" git clone --depth=1 "$url" "$dst"
    fi
  done
}

# ============================================
# 4. Install TPM (Tmux Plugin Manager)
# ============================================
install_tpm() {
  ui_step "TPM (tmux plugin manager)"
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    ui_run "tpm" git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  else
    ui_ok "already installed"
  fi
}

# ============================================
# 5. Link dotfiles
# ============================================
link_dotfiles() {
  ui_step "Dotfiles"

  # Zsh files
  link_file "$DOTFILES_ROOT/zsh/zshrc.symlink" "$HOME/.zshrc"
  link_file "$DOTFILES_ROOT/zsh/zprofile.symlink" "$HOME/.zprofile"
  link_file "$DOTFILES_ROOT/zsh/zshenv.symlink" "$HOME/.zshenv"
  link_file "$DOTFILES_ROOT/zsh/p10k.zsh.symlink" "$HOME/.p10k.zsh"

  # Tmux
  link_file "$DOTFILES_ROOT/tmux/tmux.conf.symlink" "$HOME/.tmux.conf"

  # Git
  link_file "$DOTFILES_ROOT/git/gitconfig.symlink" "$HOME/.gitconfig"
  link_file "$DOTFILES_ROOT/git/gitignore_global.symlink" "$HOME/.gitignore_global"

  # Config directory
  mkdir -p "$HOME/.config"

  # Neovim
  link_file "$DOTFILES_ROOT/config.symlink/nvim" "$HOME/.config/nvim"

  # Dotfiles symlink (for zsh modules to work)
  link_file "$DOTFILES_ROOT" "$HOME/.dotfiles"

  links_summary
}

# ============================================
# 6. Set zsh as default shell
# ============================================
set_zsh_default() {
  ui_step "Default shell"
  if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)"
    ui_ok "zsh set as default shell ${C_DIM}(restart terminal to apply)${C_RESET}"
  else
    ui_ok "zsh is already the default shell"
  fi
}

# ============================================
# 7. Install optional tools
# ============================================
install_optional_tools() {
  ui_step "Optional tools"

  # atuin (shell history)
  if command -v atuin &>/dev/null; then
    ui_info "${C_DIM}atuin already installed${C_RESET}"
  else
    ui_run "atuin" sh -c 'curl --proto "=https" --tlsv1.2 -LsSf https://setup.atuin.sh | sh' || true
  fi

  # yazi (file manager)
  if ! command -v yazi &>/dev/null; then
    ui_warn "yazi not installed — grab it from https://github.com/sxyazi/yazi/releases"
  fi
}

# ============================================
# Main
# ============================================
main() {
  ui_banner "Pop!_OS dotfiles setup" "neovim · tmux · zsh"
  ui_steps_total 7

  install_packages
  install_ohmyzsh
  install_zsh_plugins
  install_tpm
  link_dotfiles
  set_zsh_default
  install_optional_tools

  ui_done "Setup complete!"
  printf '  %sNext steps%s\n' "$C_BOLD" "$C_RESET"
  printf '  1. Restart terminal or run: %sexec zsh%s\n' "$C_CYAN" "$C_RESET"
  printf '  2. In tmux press %sprefix + I%s to install tmux plugins\n' "$C_CYAN" "$C_RESET"
  printf '  3. Open %snvim%s — lazy.nvim installs plugins automatically\n\n' "$C_CYAN" "$C_RESET"
}

main "$@"
