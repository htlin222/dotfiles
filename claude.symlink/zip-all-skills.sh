#!/usr/bin/env bash
# Zip each skill folder individually: skill/skill.zip
set -euo pipefail

SKILLS_DIR="$(cd "$(dirname "$0")/skills" && pwd)"

for dir in "$SKILLS_DIR"/*/; do
  name="$(basename "$dir")"
  zip -r "/tmp/${name}.zip" "$dir" -x '*.zip' && \
    command mv "/tmp/${name}.zip" "${dir}${name}.zip" && \
    echo "✓ ${name}"
done
