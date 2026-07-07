#!/bin/bash
# Claude marker jump. Used by prefix+b only.
# First press: enter copy-mode, jump to last message (❯), auto-scroll down.
# Next presses: stop scroll, jump to previous message, restart scroll.
# No delay between stop/restart — token-based supersession handles it.
# prefix+q/Escape/J/K/mouse to stop.

in_copy=$(tmux display-message -p '#{pane_in_mode}')

if [ "$in_copy" != "1" ]; then
    # First press: enter copy-mode, skip visible area
    tmux copy-mode
    sleep 0.05
    tmux send-keys -X top-line
fi

# Stop current auto-scroll so search doesn't race
tmux set-option -pq @auto_scroll off 2>/dev/null

tmux send-keys -X search-backward "^❯"
sleep 0.1

# Position found message at top of viewport
copy_y=$(tmux display-message -p '#{copy_cursor_y}')
[ "$copy_y" -gt 0 ] && tmux send-keys -X -N "$copy_y" scroll-down

# Start auto-scroll (new instance supersedes any old one via token)
~/.config/tmux/tmux.sh auto-scroll down &
