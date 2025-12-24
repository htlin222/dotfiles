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
    xdg-open "$file"
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
