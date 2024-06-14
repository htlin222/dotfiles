#!/bin/bash
# title: serve-marp
# date created: "2023-08-28"

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title server slide
# @raycast.mode silent
# @raycast.packageName Browsing
# Optional parameters:
# @raycast.icon 🍽️
# Documentation:
# @raycast.author Hsieh.Ting Lin
# @raycast.description Server slide

marp ~/Dropbox/slides/ -s --engine ~/Dropbox/slides/engine.js --html
echo "serve marp"
exit 0
