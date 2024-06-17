#!/bin/bash
# title: "tmux_popup"
# author: Hsieh-Ting Lin
# date: "2024-06-17"
# version: 1.0.0
# description:
# [不會關掉的 tmux popup - HackMD](https://hackmd.io/@DailyOops/persistent-tmux-popup?type=view)

# --END-- #

# Automatically fetch the current window ID and session name
window_id=$(tmux display-message -p '#I')
current_session_name=$(tmux display-message -p '#S')

# Fetch the current directory of the parent session
parent_session_dir=$(tmux display-message -p -F "#{pane_current_path}" -t0)

# Construct the unique session name with a "floating" suffix
# session_name="floating_${current_session_name}_${window_id}"
# 如果你想讓單一個 session 共享 popup，把後面 window_id 拿掉即可
session_name="floating_${current_session_name}"

startup_command="$1"

# Check if the floating popup session already exists
if tmux has-session -t "$session_name" 2>/dev/null; then
	tmux popup -w 90% -h 80% -E "bash -c \"tmux attach -t $session_name\""
else
	if [ -z "$startup_command" ]; then
		# If no startup command is provided, just open a shell
		tmux new-session -d -s "$session_name" -c "$parent_session_dir"
	else
		# If a startup command is provided, run it in the new session
		tmux new-session -d -s "$session_name" -c "$parent_session_dir" "$startup_command"
	fi
	tmux popup -w 90% -h 80% -E "bash -c \"tmux attach -t $session_name\"" # Attach to the session in a popup
fi
