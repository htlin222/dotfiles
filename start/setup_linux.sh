#!/usr/bin/env bash
#
# Linux (Pop!_OS) setup for neovim, tmux, and zsh
#

set -e

cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd -P)

info () {
  printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  exit 1
}

# ============================================
# 1. Install system packages
# ============================================
install_packages() {
  info "Installing system packages..."
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
  if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
    mkdir -p ~/.local/bin
    ln -sf $(which fdfind) ~/.local/bin/fd
  fi

  success "System packages installed"
}

# ============================================
# 2. Install Oh-My-Zsh
# ============================================
install_ohmyzsh() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    success "Oh-My-Zsh installed"
  else
    success "Oh-My-Zsh already installed"
  fi
}

# ============================================
# 3. Install Zsh plugins
# ============================================
install_zsh_plugins() {
  local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  info "Installing zsh plugins..."

  # Powerlevel10k theme
  if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
  fi

  # zsh-autosuggestions
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  fi

  # fast-syntax-highlighting
  if [ ! -d "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" ]; then
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"
  fi

  # zsh-vi-mode
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-vi-mode" ]; then
    git clone https://github.com/jeffreytse/zsh-vi-mode "$ZSH_CUSTOM/plugins/zsh-vi-mode"
  fi

  # fzf-tab
  if [ ! -d "$ZSH_CUSTOM/plugins/fzf-tab" ]; then
    git clone https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"
  fi

  # zsh-autopair
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autopair" ]; then
    git clone https://github.com/hlissner/zsh-autopair "$ZSH_CUSTOM/plugins/zsh-autopair"
  fi

  # zsh-lazyload
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-lazyload" ]; then
    git clone https://github.com/qoomon/zsh-lazyload "$ZSH_CUSTOM/plugins/zsh-lazyload"
  fi

  # zsh-auto-notify
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-auto-notify" ]; then
    git clone https://github.com/MichaelAquilina/zsh-auto-notify.git "$ZSH_CUSTOM/plugins/zsh-auto-notify"
  fi

  success "Zsh plugins installed"
}

# ============================================
# 4. Install TPM (Tmux Plugin Manager)
# ============================================
install_tpm() {
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    info "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    success "TPM installed"
  else
    success "TPM already installed"
  fi
}

# ============================================
# 5. Link dotfiles
# ============================================
link_file() {
  local src=$1 dst=$2

  if [ -L "$dst" ]; then
    rm "$dst"
  elif [ -f "$dst" ] || [ -d "$dst" ]; then
    mv "$dst" "${dst}.backup"
    info "Backed up $dst to ${dst}.backup"
  fi

  ln -s "$src" "$dst"
  success "Linked $src → $dst"
}

link_dotfiles() {
  info "Linking dotfiles..."

  # Zsh files
  link_file "$DOTFILES_ROOT/zsh/zshrc.symlink" "$HOME/.zshrc"
  link_file "$DOTFILES_ROOT/zsh/zprofile.symlink" "$HOME/.zprofile"
  link_file "$DOTFILES_ROOT/zsh/zshenv.symlink" "$HOME/.zshenv"

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

  success "Dotfiles linked"
}

# ============================================
# 6. Set zsh as default shell
# ============================================
set_zsh_default() {
  if [ "$SHELL" != "$(which zsh)" ]; then
    info "Setting zsh as default shell..."
    chsh -s $(which zsh)
    success "Zsh set as default shell (restart terminal to apply)"
  else
    success "Zsh is already default shell"
  fi
}

# ============================================
# 7. Install optional tools
# ============================================
install_optional_tools() {
  info "Installing optional tools..."

  # atuin (shell history)
  if ! command -v atuin &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
  fi

  # yazi (file manager)
  if ! command -v yazi &> /dev/null; then
    info "Note: Install yazi manually from https://github.com/sxyazi/yazi/releases"
  fi

  success "Optional tools check complete"
}

# ============================================
# Main
# ============================================
main() {
  echo ""
  echo "╔═══════════════════════════════════════════╗"
  echo "║  Pop!_OS Dotfiles Setup                   ║"
  echo "║  (neovim, tmux, zsh)                      ║"
  echo "╚═══════════════════════════════════════════╝"
  echo ""

  install_packages
  install_ohmyzsh
  install_zsh_plugins
  install_tpm
  link_dotfiles
  set_zsh_default
  install_optional_tools

  echo ""
  echo "╔═══════════════════════════════════════════╗"
  echo "║  Setup complete!                          ║"
  echo "╠═══════════════════════════════════════════╣"
  echo "║  Next steps:                              ║"
  echo "║  1. Restart terminal or run: exec zsh    ║"
  echo "║  2. Open tmux and press: prefix + I       ║"
  echo "║     to install tmux plugins               ║"
  echo "║  3. Open nvim to let lazy.nvim install    ║"
  echo "║     plugins automatically                 ║"
  echo "╚═══════════════════════════════════════════╝"
  echo ""
}

main "$@"
