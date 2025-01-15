#!/bin/bash
# title: to_html
# date created: "2023-09-30"

marp --theme "$HOME/Dropbox/slides/contents/themes/main.css" "$1" --engine "$HOME/Dropbox/slides/src/engine.js" --bespoke.progress --html -o "${1%.*}/index.html"

cd ${1%.*}

exit 0
