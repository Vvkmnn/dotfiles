#!/bin/bash

# Beautiful move-window chooser - search all windows across all sessions
# Recycles the exact same beautiful styling as window search (` + Enter)

CURRENT_SESSION=$(tmux display-message -p '#S')
CURRENT_WINDOW=$(tmux display-message -p '#I')

# Generate list of sessions for moving
{
    # Option 1: Create new session (always at top)
    echo "new session"
    
    # Option 2+: All existing sessions (including current)
    tmux list-sessions -F '#{session_name}'
} > /tmp/tmux_sessions.txt

# Use fzf to select session
selected=$(cat /tmp/tmux_sessions.txt | \
fzf --reverse \
    --no-info \
    --no-scrollbar \
    --header='🚀 Move current window to (search all sessions):' \
    --preview='~/.config/tmux/preview_session.sh {}' \
    --preview-window='right:60%:wrap:noborder' \
    --color='hl:#50fa7b,hl+:#50fa7b' \
    --algo=v2 \
    --scheme=path \
    --ansi)

# Clean up temp file
rm -f /tmp/tmux_sessions.txt

# Process selection
if [[ -n "$selected" ]]; then
    if [[ "$selected" == "new session" ]]; then
        # Create new session with auto-generated name and move current window
        new_session="session_$(date +%s)"
        
        # Debug: Show what we're about to do
        echo "Current: ${CURRENT_SESSION}:${CURRENT_WINDOW}"
        echo "Creating new session: ${new_session}"
        echo "Command will be: tmux move-window -s '${CURRENT_SESSION}:${CURRENT_WINDOW}' -t '${new_session}:1'"
        
        # Test if current session and window exist
        if tmux list-windows -t "${CURRENT_SESSION}" | grep -q "^${CURRENT_WINDOW}:"; then
            echo "Source window exists, proceeding with move..."
            
            # Move current window to new session (this creates the session automatically)
            if tmux move-window -s "${CURRENT_SESSION}:${CURRENT_WINDOW}" -t "${new_session}:1"; then
                echo "Move successful, switching to new session..."
                tmux switch-client -t "$new_session"
            else
                echo "Move failed! Trying alternative approach..."
                # Fallback: create session first, then move
                tmux new-session -d -s "$new_session"
                tmux move-window -s "${CURRENT_SESSION}:${CURRENT_WINDOW}" -t "${new_session}:"
                tmux switch-client -t "$new_session"
            fi
        else
            echo "ERROR: Source window ${CURRENT_SESSION}:${CURRENT_WINDOW} not found!"
            tmux list-windows -t "${CURRENT_SESSION}"
        fi
    else
        # Move current window to selected session
        target_session="$selected"
        
        # Debug: Show what we're about to do
        echo "Moving window ${CURRENT_SESSION}:${CURRENT_WINDOW} to session ${target_session}"
        
        # Move current window to target session
        tmux move-window -s "${CURRENT_SESSION}:${CURRENT_WINDOW}" -t "${target_session}:"
        tmux switch-client -t "$target_session"
    fi
fi