# Development Tools Functions

# Netlify deploy
netlify_pub() {
  netlify deploy -p --dir=$1
}

# Start fetch MCP server
start_fetch_mcp() {
  local TARGET_DIR="$HOME/fetch-mcp"
  if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory $TARGET_DIR does not exist."
    return 1
  fi
  cd "$TARGET_DIR" || return 1
  nohup pnpm start >pnpm.log 2>&1 &
  disown
  echo "pnpm started in background. Logs: $TARGET_DIR/pnpm.log"
}

# Chrome debug mode (cross-platform)
chrome-debug() {
  local chrome_path
  if [[ -n "$IS_MAC" ]]; then
    chrome_path="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
  else
    chrome_path="google-chrome"
  fi
  "$chrome_path" \
    --remote-debugging-port=9222 \
    --user-data-dir="/tmp/chrome-debug" \
    --no-first-run \
    --no-default-browser-check "$@"
}

# Add path to Claude filesystem config
add_path_to_claude_filesystem() {
  if [[ -n "$IS_MAC" ]]; then
    local config_path="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
  else
    local config_path="$HOME/.config/claude/claude_desktop_config.json"
  fi
  local current_path="$(pwd)"
  local temp_file="$(mktemp)"

  if grep -Fq "$current_path" "$config_path"; then
    echo "✅ Path already exists in filesystem args."
    return 0
  fi

  if command -v jq >/dev/null 2>&1; then
    jq --arg newPath "$current_path" '
      .mcpServers.filesystem.args += [$newPath]
    ' "$config_path" > "$temp_file" && mv "$temp_file" "$config_path"
    echo "✅ Added $current_path to filesystem args."
  else
    echo "⚠️ jq not found. Please install jq or edit manually for safety."
    return 1
  fi
}

# Install specific Homebrew formula version
function brew-switch {
  local _formula=$1
  local _version=$2

  if [[ -z "$_formula" || -z "$_version" ]]; then
    echo "USAGE: brew-switch <formula> <version>"
    return 1
  fi

  if [[ -z "$(command -v gh)" ]]; then
    echo ">>> ERROR: 'gh' must be installed to run this script"
    return 1
  fi

  local _commit_url=$(
    gh search commits \
      --owner "Homebrew" \
      --repo "homebrew-core" \
      --limit 1 \
      --sort "committer-date" \
      --order "desc" \
      --json "url" \
      --jq ".[0].url" \
      "\"${_formula}\" \"${_version}\""
  )

  if [[ -z "$_commit_url" ]]; then
    echo "ERROR: No commit found for ${_formula}@${_version}"
    return 1
  else
    echo "INFO: Found commit ${_commit_url} for ${_formula}@${_version}"
  fi

  local _raw_url_base=$(
    echo "$_commit_url" |
      sed -E 's|github.com/([^/]+)/([^/]+)/commit/(.*)|raw.githubusercontent.com/\1/\2/\3|'
  )

  local _formula_path="/tmp/${_formula}.rb"

  echo ""
  local _repo_path="Formula/${_formula:0:1}/${_formula}.rb"
  local _raw_url="${_raw_url_base}/${_repo_path}"
  echo "INFO: Downloading ${_raw_url}"
  if ! curl -fL "$_raw_url" -o "$_formula_path"; then
    echo "WARNING: Download failed, trying OLD formula path"
    echo ""
    _repo_path="Formula/${_formula}.rb"
    _raw_url="${_raw_url_base}/${_repo_path}"
    echo "INFO: Downloading ${_raw_url}"
    if ! curl -fL "$_raw_url" -o "$_formula_path"; then
      echo "WARNING: Download failed, trying ANCIENT formula path"
      echo ""
      _repo_path="/Library/Formula/${_formula}.rb"
      _raw_url="${_raw_url_base}/${_repo_path}"
      echo "INFO: Downloading ${_raw_url}"
      if ! curl -fL "$_raw_url" -o "$_formula_path"; then
        echo "ERROR: Failed to download ${_formula} from ${_raw_url}"
        return 1
      fi
    fi
  fi

  if brew ls --versions "$_formula" >/dev/null; then
    echo ""
    echo "WARNING: '$_formula' already installed, do you want to uninstall it? [y/N]"
    local _reply=$(bash -c "read -n 1 -r && echo \$REPLY")
    echo ""
    if [[ $_reply =~ ^[Yy]$ ]]; then
      echo "INFO: Uninstalling '$_formula'"
      brew unpin "$_formula"
      if ! brew uninstall "$_formula"; then
        echo "ERROR: Failed to uninstall '$_formula'"
        return 1
      fi
    else
      echo "ERROR: '$_formula' is already installed, aborting"
      return 1
    fi
  fi

  echo "INFO: Installing ${_formula}@${_version} from local file: $_formula_path"
  brew install --formula "$_formula_path"
  brew pin "$_formula"
}

# Vim config
function vimconfig() {
  cd ~/.config/nvim/lua/
  nvim ~/.config/nvim/lua/options.lua
}

# Snippets config
function snippets() {
  nvim $HOME/.dotfiles/neovim/snippets/init.lua
}

# Espanso text expand config
function textexpand() {
  cd ~/.config/espanso/match
}

# OpenAI API key from 1Password
function openai() {
  export OPENAI_API_KEY=$(op read "op://Dev/chat_GPT/api key")
}

# ChatGPT CLI
function chatgpt() {
  sh "$DOTFILES/shellscripts/chatGPT_CURL.sh" -i "$1"
}

# Simplenote
function simplenote() {
  nvim -c "SimplenoteList"
}

# NCCN guidelines
function nccn() {
  cd ~/Documents/guidelines/NCCN
  sh ~/Documents/guidelines/NCCN/nccn.sh
}

# Resume last Claude Code session
function resume() {
  local session_file="$HOME/.claude/last_session_id"
  if [[ -f "$session_file" ]]; then
    local sid
    sid=$(<"$session_file")
    sid="${sid%$'\n'}"  # trim trailing newline
    if [[ -n "$sid" ]]; then
      export CURRENT_CLAUDE_CODE_SESSIONID="$sid"
      echo "Resuming session: $sid"
      claude --dangerously-skip-permissions --resume "$sid"
      return
    fi
  fi
  echo "No saved session ID found in $session_file"
  return 1
}

# Medical scripts
function sss() {
  $HOME/Dropbox/Medical/scripts/ls.sh
}
