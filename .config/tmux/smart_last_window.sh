#!/bin/bash

# Smart last-window: cross-session, activity-aware window switching
# Prioritizes windows where you actively typed, ignores quick navigation

HISTORY_FILE="/tmp/tmux-global-window-history"
CURRENT_TIME=$(date +%s)
CURRENT_WINDOW=$(tmux display-message -p '#I')
CURRENT_SESSION=$(tmux display-message -p '#S')
CURRENT_TARGET="${CURRENT_SESSION}:${CURRENT_WINDOW}"

# Get activity score based on tmux pane activity and content changes
ACTIVITY_SCORE=0

# Check if pane has been active (tmux built-in activity detection)
pane_activity=$(tmux display-message -t "${CURRENT_SESSION}:${CURRENT_WINDOW}" -p '#{pane_activity}' 2>/dev/null || echo 0)

# Check if content changed recently (indicates typing/editing)
content_hash=$(tmux capture-pane -t "${CURRENT_SESSION}:${CURRENT_WINDOW}" -p | head -20 | md5)
last_hash_file="/tmp/tmux-content-${CURRENT_SESSION}-${CURRENT_WINDOW}"

if [[ -f "$last_hash_file" ]]; then
    last_hash=$(cat "$last_hash_file")
    if [[ "$content_hash" != "$last_hash" ]]; then
        ACTIVITY_SCORE=10  # High score for content changes (typing/editing)
    else
        ACTIVITY_SCORE=1   # Low score for just viewing
    fi
else
    ACTIVITY_SCORE=5  # Medium score for new window
fi

# Save current content hash for next check
echo "$content_hash" > "$last_hash_file"

# Boost score if pane shows activity
[[ "$pane_activity" == "1" ]] && ACTIVITY_SCORE=$((ACTIVITY_SCORE + 5))

# Initialize global history file if it doesn't exist
if [[ ! -f "$HISTORY_FILE" ]]; then
    echo "${CURRENT_TARGET}:${CURRENT_TIME}:${ACTIVITY_SCORE}" > "$HISTORY_FILE"
    exit 0
fi

# Read the last entry
LAST_ENTRY=$(tail -n1 "$HISTORY_FILE")
IFS=: read -r last_target last_time last_activity <<< "$LAST_ENTRY"

# If we're in a different window/session, check dwell time and activity
if [[ "$CURRENT_TARGET" != "$last_target" ]]; then
    DWELL_TIME=$((CURRENT_TIME - last_time))
    
    # Record if dwelled > 3 seconds OR had significant activity (typing/editing)
    if [[ $DWELL_TIME -gt 3 ]] || [[ $last_activity -gt 5 ]]; then
        echo "${CURRENT_TARGET}:${CURRENT_TIME}:${ACTIVITY_SCORE}" >> "$HISTORY_FILE"
        
        # Keep only last 20 entries for cross-session history
        tail -n20 "$HISTORY_FILE" > "${HISTORY_FILE}.tmp" && mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"
    else
        # Update current entry without adding new record
        sed -i '' "s|${last_target}:.*|${CURRENT_TARGET}:${CURRENT_TIME}:${ACTIVITY_SCORE}|" "$HISTORY_FILE"
    fi
fi

# Find the best target window across ALL sessions
# Prioritize by: 1) Recent activity, 2) Recent time, 3) Exists
TARGET=""
BEST_SCORE=0
while IFS=: read -r target_session target_window timestamp activity; do
    full_target="${target_session}:${target_window}"
    
    if [[ "$full_target" != "$CURRENT_TARGET" ]]; then
        # Check if this session:window still exists
        if tmux has-session -t "$target_session" 2>/dev/null && \
           tmux list-windows -t "$target_session" -F '#I' | grep -q "^${target_window}$"; then
            
            # Calculate composite score: heavily weight activity over recency
            time_score=$((CURRENT_TIME - timestamp))
            time_score=$((time_score > 600 ? 0 : (600 - time_score) / 60))  # Max 10 points for recency (10 min)
            total_score=$((activity * 5 + time_score))  # Weight activity much higher (5x)
            
            if [[ $total_score -gt $BEST_SCORE ]]; then
                BEST_SCORE=$total_score
                TARGET="$full_target"
            fi
        fi
    fi
done < <(tac "$HISTORY_FILE")

# Switch to target window/session if found
if [[ -n "$TARGET" ]]; then
    tmux switch-client -t "$TARGET"
else
    # Fallback to tmux's built-in last-window
    tmux last-window 2>/dev/null || tmux switch-client -l 2>/dev/null || true
fi