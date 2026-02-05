#!/bin/bash
# title: to_a4
# date created: "2023-10-13"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./shellscripts/lib.sh
source "$SCRIPT_DIR/lib.sh"

marp --theme $HOME/Dropbox/slides/themes/watermark.css "$1" --engine $HOME/Dropbox/slides/engine.js --html -o "$HOME/Dropbox/tmp/${1%.*}.pdf" --allow-local-files --pdf-outlines --pdf-outlines.pages=false --pdf-notes
open_cmd "$HOME/Dropbox/tmp/"

exit 0
