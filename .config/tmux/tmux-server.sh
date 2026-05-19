#!/bin/bash
# tmux server wrapper for launchd — crash recovery + guaranteed session restore
# launchd can't track tmux's daemon process after start-server forks,
# so this script polls the socket and restarts on crash.
# After each restart, verifies continuum restored sessions.
export PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin
export HOME=/Users/v

TMUX=/opt/homebrew/bin/tmux
RESTORE=$HOME/.config/tmux/plugins/tmux-resurrect/scripts/restore.sh
LOG=/tmp/tmux-launchd.log

while true; do
    echo "$(date): Starting tmux server..." >> "$LOG"
    $TMUX start-server 2>/dev/null

    # Wait for continuum restore to finish (it sleeps 1s + restore takes ~2s)
    sleep 5

    # Verify restore happened — if only 0-1 sessions exist and a save has more,
    # continuum failed to restore. Manually trigger it.
    session_count=$($TMUX list-sessions 2>/dev/null | wc -l | tr -d ' ')
    if [ "$session_count" -le 1 ] && [ -f "$HOME/.local/share/tmux/resurrect/last" ]; then
        saved_sessions=$(grep '^window' "$HOME/.local/share/tmux/resurrect/last" 2>/dev/null | awk -F'\t' '{print $2}' | sort -u | wc -l | tr -d ' ')
        if [ "$saved_sessions" -gt "$session_count" ]; then
            echo "$(date): Continuum restore incomplete ($session_count sessions, save has $saved_sessions). Manual restore..." >> "$LOG"
            bash "$RESTORE" 2>> "$LOG"
        fi
    fi

    # Poll until server dies
    while $TMUX info &>/dev/null; do
        sleep 5
    done
    echo "$(date): tmux server died, restarting in 2s..." >> "$LOG"
    sleep 2
done
