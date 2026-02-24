# FZF Related Functions

# FZF with preview
function fzf-pre() {
  fzf -m --height 50% \
    --layout=reverse \
    --inline-info \
    --preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200' \
    --preview-window 'right,50%,+{2}+3/3,~3,noborder' \
    --bind '?:toggle-preview'
}

# Ripgrep with nvim (current dir)
function rgnv() {
  rg_prefix='rg -i --column --line-number --no-heading --sort=modified --color=always --smart-case --glob "*.md" --max-depth 1'
  local result=$(fzf --bind "start:reload($rg_prefix '' | uniq)" \
    --bind "change:reload($rg_prefix {q} | uniq || true)" \
    --bind "enter:execute(echo {} | tee /tmp/fzf_result)+abort" \
    --ansi --disabled \
    --height 80% --layout=reverse \
    --exit-0)

  if [ -s /tmp/fzf_result ]; then
    local result=$(cat /tmp/fzf_result)
    local filename=$(echo $result | cut -d':' -f1)
    local number=$(echo $result | sed 's/^[^:]*://; s/:.*//')
    rm -f /tmp/fzf_result
    nvim +$number "$filename"
  fi
}

# Ripgrep TODO items
function rgtodo() {
  rg_prefix='rg -i --column --line-number --no-heading --sort=modified --color=always --smart-case --glob "*.md" "TODO:"'
  local result=$(fzf --bind "start:reload($rg_prefix '' | uniq)" \
    --bind "change:reload($rg_prefix {q} | uniq || true)" \
    --bind "enter:execute(echo {} | tee /tmp/fzf_result)+abort" \
    --ansi --disabled \
    --height 80% --layout=reverse \
    --exit-0)

  if [ -s /tmp/fzf_result ]; then
    local result=$(cat /tmp/fzf_result)
    local filename=$(echo $result | cut -d':' -f1)
    local number=$(echo $result | sed 's/^[^:]*://; s/:.*//')
    rm -f /tmp/fzf_result
    nvim +$number "$filename"
  fi
}

# FZF + nvim
function neovim_fzf() {
  FILE=$(fzf-pre)
  if [ -n "$FILE" ]; then
    nvim +10 "$FILE"
  fi
}

# Simple vim + fzf
function vimfzf() {
  nvim "$(fzf-pre)"
}

# Vim grep with quickfix
vg() {
  local pattern="$1"
  shift
  nvim -q <(rg --vimgrep "$pattern" "$@") -c "copen"
}

# RGA (ripgrep-all) with fzf
function rga-fzf() {
  RG_PREFIX="rga --files-with-matches"
  local file
  file="$(
    FZF_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
      fzf --sort --preview="[[ ! -z {} ]] && rga --pretty --context 5 {q} {}" \
      --phony -q "$1" \
      --bind "change:reload:$RG_PREFIX {q}" \
      --preview-window="70%:wrap"
  )" &&
    echo "opening $file" &&
    {
      if command -v xdg-open &>/dev/null; then
        xdg-open "$file"
      elif command -v open &>/dev/null; then
        open "$file"
      elif command -v gio &>/dev/null; then
        gio open "$file"
      else
        echo "No open command found (xdg-open/open/gio)" >&2
        return 127
      fi
    }
}

# FZF tmux navigator — sessions →(→)→ windows →(→)→ panes (←: back)
function fzftmux() {
  local tmpdir=$(mktemp -d)
  trap "command rm -rf '$tmpdir'" RETURN

  # --- State ---
  printf 'sessions' > "$tmpdir/mode"
  printf '' > "$tmpdir/current_session"
  printf '' > "$tmpdir/current_window"

  # --- List: sessions ---
  cat > "$tmpdir/sessions" << 'EOF'
#!/bin/sh
tmux ls -F "#{session_name}|#{session_windows}|#{session_attached}" 2>/dev/null | while IFS='|' read -r name wins att; do
  if [ "$att" -gt 0 ]; then
    printf "\033[32m▶ %-20s \033[36m⧉ %s win  \033[33m● attached\033[0m\n" "$name" "$wins"
  else
    printf "\033[37m▷ %-20s \033[36m⧉ %s win  \033[90m○ detached\033[0m\n" "$name" "$wins"
  fi
done
EOF

  # --- List: windows ---
  cat > "$tmpdir/windows" << 'EOF'
#!/bin/sh
sess="$1"
tmux list-windows -t "$sess" -F "#{window_index}|#{window_name}|#{pane_current_command}|#{pane_current_path}|#{window_active}" 2>/dev/null | while IFS='|' read -r idx wname cmd cpath active; do
  dir=$(echo "$cpath" | sed "s|^$HOME|~|")
  if [ "$active" = "1" ]; then
    printf "\033[32m▸ %s: %-14s \033[33m⚙ %s  \033[36m📂 %s\033[0m\n" "$idx" "$wname" "$cmd" "$dir"
  else
    printf "\033[37m  %s: %-14s \033[90m⚙ %s  📁 %s\033[0m\n" "$idx" "$wname" "$cmd" "$dir"
  fi
done
EOF

  # --- List: panes ---
  cat > "$tmpdir/panes" << 'EOF'
#!/bin/sh
sess="$1"; win="$2"
tmux list-panes -t "${sess}:${win}" -F "#{pane_index}|#{pane_current_command}|#{pane_current_path}|#{pane_active}|#{pane_width}x#{pane_height}" 2>/dev/null | while IFS='|' read -r idx cmd cpath active size; do
  dir=$(echo "$cpath" | sed "s|^$HOME|~|")
  if [ "$active" = "1" ]; then
    printf "\033[32m◻ %s  ⚙ %-12s 📂 %-30s \033[90m%s\033[0m\n" "$idx" "$cmd" "$dir" "$size"
  else
    printf "\033[37m◻ %s  \033[90m⚙ %-12s 📁 %-30s %s\033[0m\n" "$idx" "$cmd" "$dir" "$size"
  fi
done
EOF

  # --- Universal preview (mode-aware) ---
  cat > "$tmpdir/preview" << 'PREVIEW_EOF'
#!/bin/sh
line="$1"; tmpdir="$2"
mode=$(cat "$tmpdir/mode" 2>/dev/null)

case "$mode" in
  sessions)
    sess=$(printf '%s' "$line" | sed 's/\x1b\[[0-9;]*m//g;s/.*[▶▷] *//;s/ .*//')
    [ -z "$sess" ] && exit 0
    printf "\033[35m◈ %s\033[0m\n\n" "$sess"
    tmux list-windows -t "$sess" -F "#{window_index}|#{window_name}|#{pane_current_command}|#{pane_current_path}|#{window_active}" 2>/dev/null | while IFS='|' read -r idx wname cmd cpath active; do
      dir=$(echo "$cpath" | sed "s|^$HOME|~|")
      if [ "$active" = "1" ]; then
        printf "\033[32m  ▸ %s:\033[1m%-14s \033[33m⚙ %s  \033[36m📂 %s\033[0m\n" "$idx" "$wname" "$cmd" "$dir"
      else
        printf "\033[90m    %s:\033[0m%-14s \033[90m⚙ %s  📁 %s\033[0m\n" "$idx" "$wname" "$cmd" "$dir"
      fi
    done
    ;;
  windows)
    sess=$(cat "$tmpdir/current_session" 2>/dev/null | tr -d '[:space:]')
    win=$(printf '%s' "$line" | sed 's/\x1b\[[0-9;]*m//g;s/.*[▸ ] *\([0-9]*\):.*/\1/')
    [ -z "$sess" ] || [ -z "$win" ] && exit 0
    printf "\033[35m◈ %s:%s\033[0m\n\n" "$sess" "$win"
    tmux capture-pane -e -t "${sess}:${win}" -p 2>/dev/null
    ;;
  panes)
    sess=$(cat "$tmpdir/current_session" 2>/dev/null | tr -d '[:space:]')
    win=$(cat "$tmpdir/current_window" 2>/dev/null | tr -d '[:space:]')
    pane=$(printf '%s' "$line" | sed 's/\x1b\[[0-9;]*m//g;s/.*◻ *\([0-9]*\) .*/\1/')
    [ -z "$pane" ] && exit 0
    printf "\033[35m◈ %s:%s.%s\033[0m\n\n" "$sess" "$win" "$pane"
    tmux capture-pane -e -t "${sess}:${win}.${pane}" -p 2>/dev/null
    ;;
esac
PREVIEW_EOF

  chmod +x "$tmpdir"/{sessions,windows,panes,preview}

  local target
  target=$(sh "$tmpdir/sessions" | \
    fzf --ansi --height 80% --layout=reverse \
      --prompt="sessions › " \
      --header=$'\033[90mEnter: attach  →: drill in  ←: back\033[0m' \
      --preview "sh $tmpdir/preview {} $tmpdir" \
      --preview-window=right:55%:wrap \
      --bind "right:transform:
        case {fzf:prompt} in
          *panes*) ;;
          *windows*)
            sess=\$(cat $tmpdir/current_session | tr -d '[:space:]')
            win=\$(printf '%s' {} | sed 's/\x1b\[[0-9;]*m//g;s/.*[▸ ] *\([0-9]*\):.*/\1/')
            pc=\$(tmux list-panes -t \"\${sess}:\${win}\" 2>/dev/null | wc -l | tr -d ' ')
            if [ \"\$pc\" -gt 1 ]; then
              printf '%s' \"\$win\" > $tmpdir/current_window
              printf 'panes' > $tmpdir/mode
              echo \"reload(sh $tmpdir/panes \$sess \$win)+change-prompt(\$sess:\$win › panes › )\"
            fi ;;
          *sessions*)
            sess=\$(printf '%s' {} | sed 's/\x1b\[[0-9;]*m//g;s/.*[▶▷] *//;s/ .*//')
            printf '%s' \"\$sess\" > $tmpdir/current_session
            printf 'windows' > $tmpdir/mode
            echo \"reload(sh $tmpdir/windows \$sess)+change-prompt(\$sess › windows › )\" ;;
        esac" \
      --bind "left:transform:
        case {fzf:prompt} in
          *panes*)
            sess=\$(cat $tmpdir/current_session | tr -d '[:space:]')
            printf '' > $tmpdir/current_window
            printf 'windows' > $tmpdir/mode
            echo \"reload(sh $tmpdir/windows \$sess)+change-prompt(\$sess › windows › )\" ;;
          *windows*)
            printf '' > $tmpdir/current_session
            printf 'sessions' > $tmpdir/mode
            echo \"reload(sh $tmpdir/sessions)+change-prompt(sessions › )\" ;;
        esac"
  )

  [[ -z "$target" ]] && return

  local current_sess=$(cat "$tmpdir/current_session" 2>/dev/null | tr -d '[:space:]')
  local current_win=$(cat "$tmpdir/current_window" 2>/dev/null | tr -d '[:space:]')
  local stripped=$(printf '%s' "$target" | sed 's/\x1b\[[0-9;]*m//g')

  if [[ -n "$current_win" ]]; then
    local pane=$(printf '%s' "$stripped" | sed 's/.*◻ *\([0-9]*\) .*/\1/')
    tmux attach-session -t "${current_sess}:${current_win}.${pane}"
  elif [[ -n "$current_sess" ]]; then
    local win=$(printf '%s' "$stripped" | sed 's/.*[▸ ] *\([0-9]*\):.*/\1/')
    tmux attach-session -t "${current_sess}:${win}"
  else
    local sess=$(printf '%s' "$stripped" | sed 's/.*[▶▷] *//;s/ .*//')
    tmux attach-session -t "$sess"
  fi
}

# Delete line from file with fzf
function delete_line_with_fzf() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo "文件 $file 不存在"
    return 1
  fi
  local selected_line=$(cat "$file" | fzf)
  if [[ -n "$selected_line" ]]; then
    echo "上下文行："
    grep -C 1 -F "$selected_line" "$file" | sed "s/$selected_line/\x1b[31m&\x1b[0m/"
    local temp_file=$(mktemp)
    grep -vF "$selected_line" "$file" >"$temp_file"
    if [[ $? -eq 0 ]]; then
      mv "$temp_file" "$file"
      echo -e "\n已刪除的行：\x1b[31m$selected_line\x1b[0m"
    else
      echo "刪除過程中發生錯誤"
      rm "$temp_file"
      return 1
    fi
  else
    echo "未選定任何行"
  fi
}
