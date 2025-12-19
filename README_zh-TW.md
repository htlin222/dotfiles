---
title: "htlin 的 dotfiles"
slug: "readme-zh-tw"
date: "2023-02-16"
enableToc: false
---

# htlin 的 dotfiles

> Dotfiles 是你個人化系統的方式，這是我的設定檔。

這是我個人的 macOS 開發環境設定檔，包含 Zsh、Neovim、tmux 以及各種現代化命令列工具的配置。

**[English README](README.md)**

## 功能特色

- **Zsh** 搭配 Oh-My-Zsh 與 Powerlevel10k 主題
- **Neovim** 編輯器配置
- **tmux** 終端多工管理
- **Git** 設定檔與實用別名
- **現代化命令列工具**：fzf、ripgrep、fd、lsd、lazygit 等
- **自動化安裝**：透過 bootstrap 腳本一鍵設定
- **Homebrew** 套件管理與 Brewfile

## 快速開始

### 前置需求

- macOS（已測試）或 Linux
- Git
- 網路連線

### 1. 將預設 Shell 改為 Zsh

```bash
sudo -v && \
chsh -s /bin/zsh && \
touch ~/.hushlogin
```

### 2. 安裝 Homebrew

[Homebrew](https://brew.sh/index_zh-tw) 是 macOS 缺少的套件管理工具。

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# 請依照指示將 Homebrew 加入 PATH
```

### 3. 安裝必要工具並複製此專案

```bash
brew install wget gh && \
brew install --cask iterm2 microsoft-edge 1password logitech-options
```

登入 GitHub 並複製專案：

```bash
gh auth login
gh repo clone htlin222/dotfiles ~/.dotfiles
```

### 4. 透過 Brewfile 安裝套件

```bash
brew bundle --file="~/.dotfiles/Brewfile"
brew cleanup --prune=all
rm -rf "$(brew --cache)"
```

### 5. 執行 dotfiles 設定

```bash
cd ~/.dotfiles/start
./link_dotfiles
```

這會將設定檔以符號連結（symlink）的方式連結到你的家目錄。

## Oh-My-Zsh 設定

```bash
# 安裝 Oh-My-Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 安裝外掛
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/jeffreytse/zsh-vi-mode $ZSH_CUSTOM/plugins/zsh-vi-mode
git clone https://github.com/qoomon/zsh-lazyload $ZSH_CUSTOM/plugins/zsh-lazyload
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git $ZSH_CUSTOM/plugins/you-should-use
git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
```

## 包含內容

| 類別   | 檔案                             |
| ------ | -------------------------------- |
| Shell  | `.zshrc`、`.zshenv`、`.zprofile` |
| Git    | `.gitconfig`、`.gitignore`       |
| tmux   | `.tmux.conf`                     |
| Neovim | `.config/nvim/`                  |
| R      | `.Rprofile`                      |

## 選用：修復 Homebrew PATH

如果 Homebrew 安裝的程式沒有出現在 `/usr/local/bin`：

```bash
sudo mkdir -p /usr/local/bin && \
sudo ln -s /opt/homebrew/bin/im-select /usr/local/bin/im-select && \
sudo ln -s /opt/homebrew/bin/nvim /usr/local/bin/nvim && \
sudo ln -s /opt/homebrew/bin/node /usr/local/bin/node
```

## 選用：使用 pyenv 設定 Python

```bash
# 尋找並安裝 Python 版本
pyenv install -l | grep 3\\.12\\.
pyenv install 3.12.0

# 為 Neovim 建立虛擬環境
pyenv virtualenv 3.12.0 neovim3
pyenv activate neovim3
pip install neovim pynvim
pyenv deactivate
```

## macOS 系統設定

套用建議的 macOS 設定：

```bash
sh ~/.dotfiles/macos.sh
```

## 疑難排解

### 應用程式顯示「已損毀，無法打開」

```bash
sudo xattr -r -d com.apple.quarantine /path/to/app.app
```

## 文件

如需完整的終端機開發工作流程指南，請參閱 [docs](docs/) 目錄，其中包含《終端人生》(The Terminal Way) 完整指南，涵蓋：

- Shell 設定與客製化
- tmux 終端多工管理
- Neovim 設定與使用
- 現代化命令列工具（fzf、ripgrep、fd 等）
- Git 工作流程優化
- 以及更多內容

## 免責聲明

**使用風險自負。** 此儲存庫包含我個人的設定檔與腳本。使用前請注意：

1. **檢視程式碼** - 在執行任何腳本前，請先了解其功能
2. **備份資料** - 這些腳本可能會覆蓋現有的設定檔
3. **無保固** - 本軟體以「現狀」提供，不提供任何形式的保證
4. **不負責任** - 對於使用這些 dotfiles 造成的任何損害或資料遺失，本人概不負責
5. **先行測試** - 建議先在虛擬機器上測試，再套用到主系統

這些腳本包含的操作：

- 修改系統偏好設定
- 在家目錄建立或覆蓋符號連結
- 安裝軟體套件
- 變更 Shell 設定

**在執行任何 bootstrap 腳本前，請務必備份現有的 dotfiles。**

## 授權條款

MIT 授權條款 - 詳細授權資訊請參閱各別檔案。

## 致謝

靈感來自社群中眾多 dotfiles 專案。特別感謝所有開源工具及其維護者。
