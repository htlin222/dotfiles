#!/bin/sh
# goanna /live — read-only mirror of the shared tmux session.
# Ensures the session exists first, so a viewer connecting before the owner
# does not get a failed attach (which would look like a broken page).
TMUX_BIN=/opt/homebrew/bin/tmux
"$TMUX_BIN" has-session -t goanna 2>/dev/null \
  || "$TMUX_BIN" new-session -d -s goanna -c "$HOME" /bin/zsh -l
exec "$TMUX_BIN" attach-session -t goanna -r
