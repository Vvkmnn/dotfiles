#!/bin/bash

session="$1"

if [[ "$session" == "new session" ]]; then
    echo ""
    echo "  🆕 Create new session"
    echo ""
    echo "  Auto-generates session name"
    echo "  Moves current window to new session"
    echo ""
    exit 0
fi

echo ""
echo "  📂 Session: $session"
echo ""

# Show each window as a numbered box with content preview
tmux list-windows -t "$session" -F "#{window_index}:#{window_name}:#{pane_current_command}" 2>/dev/null | while IFS=: read -r win_idx win_name cmd; do
    echo "┌─ $win_idx: $win_name [$cmd] ────────────────────────────────────"
    tmux capture-pane -e -t "${session}:${win_idx}" -S -8 -p 2>/dev/null | /usr/bin/head -8 | /usr/bin/sed 's/^/│ /'
    echo "└────────────────────────────────────────────────────────────────"
    echo ""
done