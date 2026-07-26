#!/bin/sh
# goanna /login — writable attach to the shared tmux session.
# Creates the session (zsh at $HOME) on first connect, attaches thereafter.
exec /opt/homebrew/bin/tmux new-session -A -s goanna -c "$HOME" /bin/zsh -l
