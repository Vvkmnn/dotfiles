#!/usr/bin/env sh

# Ultra-light shared cache and smoothing
CACHE="/tmp/sketchybar_cache"
STATE_FILE="/tmp/sketchybar_state"

# Read macmon data from daemon-maintained cache (no spawn, no TTL check)
# Cache written by persistent macmon pipe in sketchybarrc
get_macmon_data() {
    [ -f "$CACHE" ] && cat "$CACHE" && return
    echo "{}"
}

# Efficient smoothing - single state file
smooth_value() {
    STAT=$1; VAL=$2; WIN=${3:-3}

    # Get current state
    CURRENT_STATE=$(awk -F: -v s="$STAT" '$1==s {print $2}' "$STATE_FILE" 2>/dev/null)

    # Update with new value (keep last WIN values)
    if [ -n "$CURRENT_STATE" ]; then
        VALS=$(echo "$CURRENT_STATE $VAL" | awk -v w=$WIN '{
            start=(NF>=w)?NF-w+1:1
            for(i=start; i<=NF; i++) printf "%s ", $i
        }')
        AVG=$(echo "$VALS" | awk '{s=0; for(i=1;i<=NF;i++) s+=$i; printf "%d", int((s/NF)+0.5)}')
    else
        VALS="$VAL"
        AVG="$VAL"
    fi

    # Atomic update
    (grep -v "^$STAT:" "$STATE_FILE" 2>/dev/null || true; echo "$STAT:$VALS") > "$STATE_FILE.tmp"
    mv "$STATE_FILE.tmp" "$STATE_FILE"

    echo "$AVG"
}
