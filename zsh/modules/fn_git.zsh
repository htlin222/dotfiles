# Git Related Functions

# Check if in git repo
function is_git_repo() {
  git rev-parse --is-inside-work-tree &>/dev/null
}

# Git add, AI commit, push
function zgit() {
  git add -A
  aicommits --type conventional
  git push
}

# Quick git add, commit, push
function ygit() {
  git add -A
  git commit -m "Routine: Upload"
  git push
}

# Git add, AI commit, push (alias style)
gitacp() {
  git add .
  aicommits
  git push
}

# Dotfiles push with AI commit
function dp() {
  cd $DOTFILES
  git -C $DOTFILES add .
  aicommits
  git -C $DOTFILES push
  cd -
}

# Dotfiles pull
function dotpull() {
  git restore $DOTFILES
  git -C $DOTFILES pull
}

# Release dotfiles with book link
dotrelease() {
  local version="$1"
  if [[ -z "$version" ]]; then
    echo "Usage: dotrelease <version> (e.g., dotrelease v1.0.3)"
    return 1
  fi
  cd "$DOTFILES" || return 1
  git tag -a "$version" -m "$version"
  git push origin "$version"
  gh release create "$version" \
    --title "$version" \
    --notes $'[終端人生：純 CLI 開發者的完全指南](https://htlin222.github.io/dotfiles/)\n\n---\n\n'"$(git log --oneline -5 | sed 's/^/- /')"
  cd -
}

# Create gist with description from file
function gist() {
  MY_FILE=$1
  DESCRIPTION=$(cat "$MY_FILE" | grep -iE 'description:|desc:' | cut -d':' -f2 | tr -d '"')
  gh gist create "$MY_FILE" --desc "$DESCRIPTION"
}

# Clone claude artifact runner template
function cloneclaude() {
  cd $HOME || {
    echo "無法切換到 $HOME"
    return 1
  }
  echo "正在克隆 htlin222/claude-artifact-runner..."
  if ! gh repo clone htlin222/claude-artifact-runner; then
    echo "克隆失敗，請檢查 gh CLI 是否正確安裝並登入。"
    return 1
  fi
  while true; do
    echo -n "請輸入新的資料夾名稱: "
    read -r new_folder_name
    if [[ -z "$new_folder_name" ]]; then
      echo "資料夾名稱不可為空，請重新輸入。"
    elif [[ -d "$new_folder_name" ]]; then
      echo "資料夾名稱已存在，請重新輸入。"
    else
      break
    fi
  done
  mv claude-artifact-runner "$new_folder_name" || {
    echo "移動資料夾失敗"
    return 1
  }
  cd "$new_folder_name" || {
    echo "無法進入資料夾 $new_folder_name"
    return 1
  }
  echo "正在執行 npm install..."
  if ! npm install; then
    echo "npm install 失敗，請檢查環境設定。"
    return 1
  fi
  echo "正在移除 .git 資料夾..."
  rm -rf .git || {
    echo "移除 .git 資料夾失敗"
    return 1
  }
  echo "正在初始化新的 Git 儲存庫..."
  git init && git add . && git commit -m 'init' || {
    echo "git 操作失敗"
    return 1
  }
  echo "專案已成功設定完成！"
}

git-top() { cd "$(git rev-parse --show-toplevel 2>/dev/null)" || return; }
