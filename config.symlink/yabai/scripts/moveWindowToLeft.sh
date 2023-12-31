#!/bin/sh
curWindowId="$(yabai -m query --windows --window | jq -re ".id")"

inputAction=$1

case $inputAction in
'display')
  $(yabai -m window --display prev || yabai -m window --display last)
  ;;
'space')
  $(yabai -m window --space prev || yabai -m window --space last)
  ;;
*)
  $(yabai -m window --space "$inputAction")
esac

$(yabai -m window --focus "$curWindowId")