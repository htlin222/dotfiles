make_flashcard() {
  local dir=~/dropbox/flashcards
  local timestamp=$(date +%Y%m%d%H%M%S)
  local filepath="$dir/$timestamp.md"

  mkdir -p "$dir" || {
    echo "❌ Failed to create directory: $dir"
    return 1
  }

  cat <<EOF >"$filepath"
# $timestamp

## Front

## Back

## Disease
EOF

  echo "✅ Flashcard created: $filepath"
  nvim "$filepath"
}
