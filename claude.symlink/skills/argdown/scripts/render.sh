#!/usr/bin/env bash
# Lint + render an .argdown file to SVG. Prints the output path on
# success so the caller can open or attach it.
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: render.sh <file.argdown> [outdir]" >&2
  exit 2
fi

file=$1
outdir=${2:-./svg}

if [[ ! -f $file ]]; then
  echo "render.sh: file not found: $file" >&2
  exit 2
fi

if ! command -v argdown >/dev/null 2>&1; then
  echo "render.sh: argdown CLI not on PATH. Install: npm i -g @argdown/cli" >&2
  exit 127
fi
if ! command -v dot >/dev/null 2>&1; then
  echo "render.sh: graphviz (dot) not on PATH. Install: brew install graphviz" >&2
  exit 127
fi

# Lint first — fail before we waste time on render.
argdown --throwExceptions "$file"

# Render. argdown map writes <stem>.svg into outdir.
mkdir -p "$outdir"
argdown map -f svg "$file" "$outdir"

stem=$(basename "$file" .argdown)
svg="$outdir/$stem.svg"
if [[ ! -f $svg ]]; then
  echo "render.sh: argdown map did not produce $svg" >&2
  exit 1
fi
echo "wrote $svg ($(wc -c <"$svg" | tr -d ' ') bytes)"
