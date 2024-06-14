#!/bin/dash

is_hide_desktop=$(defaults read com.apple.finder CreateDesktop)

if [ $is_hide_desktop -eq "1" ]; then
  defaults write com.apple.finder CreateDesktop -bool FALSE;
else
  defaults write com.apple.finder CreateDesktop -bool TRUE;
fi
killall Finder;