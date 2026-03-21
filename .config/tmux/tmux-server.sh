#!/bin/bash
# tmux server wrapper for launchd — provides crash recovery
# launchd can't track tmux's daemon process after start-server forks,
# so this script polls the socket and restarts on crash
export PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin
while true; do
    /opt/homebrew/bin/tmux start-server 2>/dev/null
    while /opt/homebrew/bin/tmux info &>/dev/null; do
        sleep 5
    done
    echo "$(date): tmux server died, restarting in 2s..."
    sleep 2
done
