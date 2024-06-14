---
title: "README"
slug: "readme"
date: "2023-02-16"
enableToc: false
---

# README

## Getting Start

see: [tutorial](tutorial.md)

### Change shell to zsh

```bash
sudo -v  && \
chsh -s /bin/zsh  && \
touch ~/.hushlogin
```

### Install howmebrew

[macOS 缺少套件的管理工具 — Homebrew](https://brew.sh/index_zh-tw)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# don't forget the last step to eval the output
```

### Install the necessary formula and cask

```bash
brew install wget defaultbrowser gh && \
brew install --cask iterm2 microsoft-edge 1password logitech-options && \
```

#### Login your github account and clone this

```bash
gh auth login
gh repo clone htlin222/dotfiles .dotfiles
```

### install the package via the Brewfile

```bash
brew bundle --file="~/.dotfiles/Brewfile"
brew cleanup --prune=all
rm -rf "$(brew --cache)"
```

### Fix Brew installs not appearing in /usr/local/bin

[installation - Brew installs not appearing in /usr/local/bin - Stack Overflow](https://stackoverflow.com/questions/70983104/brew-installs-not-appearing-in-usr-local-bin)

```bash
sudo mkdir /usr/local/bin && \
sudo ln -s /opt/homebrew/bin/im-select /usr/local/bin/im-select && \
sudo ln -s /opt/homebrew/bin/nvim /usr/local/bin/nvim && \
sudo ln -s /opt/homebrew/bin/node /usr/local/bin/node
```

---

## set up for oh-my-zsh and install the plugins

### Open WezTerm

```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# zsh-vi-mode
git clone https://github.com/jeffreytse/zsh-vi-mode $ZSH_CUSTOM/plugins/zsh-vi-mode
# zsh-lazyload
git clone https://github.com/qoomon/zsh-lazyload $ZSH_CUSTOM/plugins/zsh-lazyload
# you-should-use
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git $ZSH_CUSTOM/plugins/you-should-use
# fzf-tab
git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
```

### delete the defaut config and link the repo files

```bash
rm -rf ~/.config && \
ln -s ~/.dotfiles/.config ~/.config && \
rm .zshrc && \
ln -s ~/.dotfiles/.zshrc ~/.zshrc && \
ln -s ~/.dotfiles/pyscripts ~/pyscripts && \
ln -s ~/.dotfiles/.tmux.conf ~/.tmux.conf && \
```

> not recommended since my vimrc's path was different

## python setup ft. pyenv

```bash
# find the latest version && \
pyenv install -l | grep 3\.10\. && \
pyenv install -l | grep miniconda3-4 && \
# install && \
pyenv install 3.10.5 miniconda3-4.7.12
```

## neovim setup (optional)

### install the dependency

```bash
pyenv virtualenv 3.10.5 neovim3 && \
pyenv activate neovim3 && \
npm install --global yarn && \
pip neovim pynvim ranger-fm greenlet msgpack
```

### Start Neovim

```shell
vim -c "PlugInstall | checkhealth | UpdateRemotePlugins | qa" && \
pyenv deactivate neovim3
```

## mac OS setup

### run macos.sh

```shell
sh ~/.dotfiles/macos.sh
```

### 常用

```shell
# 關閉“你確定要開啟這個應用程式？”詢問視窗 && \
defaults write com.apple.LaunchServices LSQuarantine -bool false && \

# 開啟全部視窗組件支援鍵盤控制 && \
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3 && \
# 加快鍵盤輸入 && \
defaults write NSGlobalDomain KeyRepeat -int 0 && \
# 移除視窗截圖的影子 && \
defaults write com.apple.finder NewWindowTarget -string "PfLo" && \
# Finder 標題列顯示完整路徑 && \
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true && \
# 預設搜尋列的結果為當前目錄下 && \
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf" && \
# 關閉改變副檔名的警告提示 && \
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false && \
# 避免在 network volumes 底下建立 .DS_Store 檔案 && \
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true && \
# 關閉清空垃圾桶的警告提示 && \
defaults write com.apple.finder WarnOnEmptyTrash -bool false && \
# 加快 Mission Control 的動畫速度 && \
defaults write com.apple.dock expose-animation-duration -float 0.1 && \
# 加快 Dock 載入速度 && \
defaults write com.apple.dock autohide-time-modifier -int 0;killall Dock
```

## Others

### when showing: 已損毀 無法打開。 您應該將其丟到「垃圾桶」

```shell
sudo xattr -r -d com.apple.quarantine xxx.app
```

### displayrotation

- [Mage Software > Display Rotation Menu](http://www.magesw.com/displayrotation/)
- [displayplacer](https://github.com/jakehilborn/displayplacer)
