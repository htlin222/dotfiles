#!/bin/bash
# title: "bandwhite"
# author: Hsieh-Ting Lin
# date: "2025-05-13"
# version: 1.0.0
# description:
# --END-- #

THEME_FILE="/tmp/wezterm_theme.txt"

CURRENT="bew"
[ -f "$THEME_FILE" ] && CURRENT=$(cat "$THEME_FILE")

if [[ "$CURRENT" == "bew" ]]; then
  echo "latte" >"$THEME_FILE"
else
  echo "bew" >"$THEME_FILE"
fi

wezterm cli reload-config
