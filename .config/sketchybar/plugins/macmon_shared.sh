#!/usr/bin/env sh

# Ultra-light shared cache and smoothing
CACHE="/tmp/sketchybar_cache"
STATE_FILE="/tmp/sketchybar_state"

# Get macmon data (5s cache for better performance)
get_macmon_data() {
    if [ -f "$CACHE" ]; then
        AGE=$(($(date +%s) - $(stat -f %m "$CACHE" 2>/dev/null || echo 0)))
        [ $AGE -lt 5 ] && cat "$CACHE" && return
    fi
    
    macmon pipe --interval 100 2>/dev/null | head -1 | tee "$CACHE" || echo "{}"
}

# Efficient smoothing - single state file
smooth_value() {
    STAT=$1; VAL=$2; WIN=${3:-3}
    
    # Get current state
    CURRENT_STATE=$(awk -F: -v s="$STAT" '$1==s {print $2}' "$STATE_FILE" 2>/dev/null)
    
    # Update with new value (keep last WIN values)
    if [ -n "$CURRENT_STATE" ]; then
        VALS=$(echo "$CURRENT_STATE $VAL" | awk -v w=$WIN '{
            for(i=(NF>=w)?NF-w+1:1; i<=NF; i++) printf "%d ", $i
        }')
        AVG=$(echo "$VALS" | awk '{s=0; for(i=1;i<=NF;i++)s+=$i; print int(s/NF)}')
    else
        VALS="$VAL"
        AVG="$VAL"
    fi
    
    # Atomic update
    (grep -v "^$STAT:" "$STATE_FILE" 2>/dev/null || true; echo "$STAT:$VALS") > "$STATE_FILE.tmp"
    mv "$STATE_FILE.tmp" "$STATE_FILE"
    
    echo "$AVG"
}
