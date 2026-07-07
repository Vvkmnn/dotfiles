#!/bin/bash
# Claude marker navigation: jump between Claude reply bullets (⏺)
# Used by prefix+[ (prev) and prefix+] (next). No toggle, no auto-scroll.
direction="${1:-prev}"

# Stop any running auto-scroll
tmux set-option -pq @auto_scroll off 2>/dev/null

# Enter copy-mode only if not already in it
in_copy=$(tmux display-message -p '#{pane_in_mode}')
if [ "$in_copy" != "1" ]; then
    tmux copy-mode
    sleep 0.05
fi

# Search for Claude bullet
if [ "$direction" = "next" ]; then
    tmux send-keys -X search-forward "^⏺"
else
    tmux send-keys -X search-backward "^⏺"
fi
