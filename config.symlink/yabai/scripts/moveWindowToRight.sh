#!/bin/sh
curWindowId="$(yabai -m query --windows --window | jq -re ".id")"

inputAction=$1

case $inputAction in
'display')
  $(yabai -m window --display next || yabai -m window --display first)
  ;;
'space')
  $(yabai -m window --space next || yabai -m window --space first)
  ;;
*)
  $(yabai -m window --space $inputAction)
  ;;
esac

$(yabai -m window --focus "$curWindowId")