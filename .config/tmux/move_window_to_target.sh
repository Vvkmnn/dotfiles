#!/bin/bash

# Move current window to selected target from choose-tree
# Handles both session and window selections

target="$1"

# Get current window ID (survives move, unlike index)
window_id=$(tmux display-message -p '#{window_id}')

# Check if target is a session (no colon) or window (has colon)
if [[ "$target" == *:* ]]; then
    # Window selected - move after it
    tmux move-window -a -t "$target"
    target_session="${target%%:*}"
else
    # Session selected - append to end of session
    target_session="$target"
    last_window=$(tmux list-windows -t "$target" -F '#{window_index}' 2>/dev/null | tail -1)
    if [ -n "$last_window" ]; then
        tmux move-window -a -t "${target}:${last_window}"
    else
        tmux move-window -t "${target}:"
    fi
fi

# Switch to target session and select the moved window
tmux switch-client -t "$target_session"
tmux select-window -t "$window_id"