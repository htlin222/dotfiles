#!/bin/bash
# title: to_a4
# date created: "2023-10-13"

marp --theme $HOME/Dropbox/slides/themes/a4.css "$1" --engine $HOME/Dropbox/slides/engine.js --html -o "$HOME/Dropbox/tmp/${1%.*}.pdf" --allow-local-files --pdf-outlines --pdf-outlines.pages=false --pdf-notes
open $HOME/Dropbox/tmp/

exit 0
