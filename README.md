---
title: "htlin's dotfiles"
slug: "readme"
date: "2023-02-16"
enableToc: false
---

# htlin's dotfiles

> Your dotfiles are how you personalize your system. These are mine.

Personal dotfiles for macOS development environment, featuring Zsh, Neovim, tmux, and modern CLI tools.

**[繁體中文版 README](README_zh-TW.md)**

## Features

- **Zsh** with Oh-My-Zsh and Powerlevel10k theme
- **Neovim** configuration
- **tmux** for terminal multiplexing
- **Git** configuration with useful aliases
- **Modern CLI tools**: fzf, ripgrep, fd, lsd, lazygit, and more
- **Automated setup** via bootstrap scripts
- **Homebrew** package management with Brewfile

## Quick Start

### Prerequisites

- macOS (tested) or Linux
- Git
- Internet connection

### 1. Change shell to Zsh

```bash
sudo -v && \
chsh -s /bin/zsh && \
touch ~/.hushlogin
```

### 2. Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# Follow the instructions to add Homebrew to your PATH
```

### 3. Clone this repository

```bash
git clone https://github.com/htlin222/dotfiles.git ~/.dotfiles
```

### 4. Install packages via Brewfile

```bash
brew bundle --file="~/.dotfiles/Brewfile"
brew cleanup --prune=all
rm -rf "$(brew --cache)"
```

### 5. Bootstrap dotfiles

```bash
cd ~/.dotfiles/start
./link_dotfiles
```

This will symlink configuration files to your home directory.

## Oh-My-Zsh Setup

```bash
# Install Oh-My-Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install plugins
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/jeffreytse/zsh-vi-mode $ZSH_CUSTOM/plugins/zsh-vi-mode
git clone https://github.com/qoomon/zsh-lazyload $ZSH_CUSTOM/plugins/zsh-lazyload
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git $ZSH_CUSTOM/plugins/you-should-use
git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
```

## What's Included

| Category | Files                            |
| -------- | -------------------------------- |
| Shell    | `.zshrc`, `.zshenv`, `.zprofile` |
| Git      | `.gitconfig`, `.gitignore`       |
| tmux     | `.tmux.conf`                     |
| Neovim   | `.config/nvim/`                  |
| R        | `.Rprofile`                      |

## Optional: Fix Homebrew PATH

If Homebrew binaries don't appear in `/usr/local/bin`:

```bash
sudo mkdir -p /usr/local/bin && \
sudo ln -s /opt/homebrew/bin/im-select /usr/local/bin/im-select && \
sudo ln -s /opt/homebrew/bin/nvim /usr/local/bin/nvim && \
sudo ln -s /opt/homebrew/bin/node /usr/local/bin/node
```

## Optional: Python Setup with pyenv

```bash
# Find and install Python version
pyenv install -l | grep 3\\.12\\.
pyenv install 3.12.0

# Create virtualenv for Neovim
pyenv virtualenv 3.12.0 neovim3
pyenv activate neovim3
pip install neovim pynvim
pyenv deactivate
```

## macOS Settings

Apply recommended macOS settings:

```bash
sh ~/.dotfiles/macos.sh
```

## Troubleshooting

### App shows "damaged, can't be opened"

```bash
sudo xattr -r -d com.apple.quarantine /path/to/app.app
```

## Documentation

For a comprehensive guide to terminal-based development workflow, see the [docs](docs/) directory, which contains "The Terminal Way" - a complete guide covering:

- Shell configuration and customization
- tmux for terminal multiplexing
- Neovim setup and usage
- Modern CLI tools (fzf, ripgrep, fd, etc.)
- Git workflow optimization
- And much more...

## Disclaimer

**USE AT YOUR OWN RISK.** This repository contains my personal configuration files and scripts. Before using:

1. **Review the code** - Understand what each script does before running it
2. **Backup your data** - These scripts may overwrite existing configuration files
3. **No warranty** - This software is provided "as is", without warranty of any kind
4. **Not responsible** - I am not responsible for any damage or data loss caused by using these dotfiles
5. **Test first** - Consider testing on a virtual machine before applying to your main system

The scripts include operations that:

- Modify system preferences
- Create/overwrite symlinks in your home directory
- Install software packages
- Change shell configurations

**Always backup your existing dotfiles before running any bootstrap scripts.**

## License

MIT License - See individual files for specific licensing information.

## Acknowledgments

Inspired by various dotfiles repositories in the community. Special thanks to all the open-source tools and their maintainers.
