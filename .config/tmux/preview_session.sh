#!/bin/bash

session="$1"
index="$2"

# Debug logging
echo "DEBUG: \$1='$1' \$2='$2'" >> /tmp/preview_debug.log

[ -z "$session" ] && exit 0

if [ -z "$index" ]; then
    # Session preview - show mini captures of all windows
    windows=$(tmux list-windows -t "$session" -F '#{window_index}|#{window_name}' 2>/dev/null)
    [ -z "$windows" ] && exit 0

    while IFS='|' read -r win_idx win_name; do
        [ -z "$win_idx" ] && continue
        printf '\n═══ %s: %s ═══\n' "$win_idx" "$win_name"
        tmux capture-pane -ep -t "${session}:${win_idx}" 2>/dev/null | tail -10
    done <<< "$windows"
else
    # Window preview - show full capture
    height=$(tmux display-message -p -t "${session}:${index}" '#{pane_height}' 2>/dev/null)
    [ -z "$height" ] && height=40

    tmux capture-pane -e -t "${session}:${index}" -S "-${height}" -p 2>/dev/null
fi
