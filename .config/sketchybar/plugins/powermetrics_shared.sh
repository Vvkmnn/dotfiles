#!/usr/bin/env sh

CACHE="/tmp/sketchybar_powermetrics.json"
STATE_FILE="/tmp/sketchybar_state"
CACHE_MAX_AGE=5

# Get powermetrics data (with 5s cache)
get_powermetrics_data() {
    if [ -f "$CACHE" ]; then
        AGE=$(($(date +%s) - $(stat -f %m "$CACHE" 2>/dev/null || echo 0)))
        if [ $AGE -lt $CACHE_MAX_AGE ]; then
            cat "$CACHE"
            return
        fi
    fi

    # Call powermetrics (with sudo, no password needed)
    # Write plist to temp file first
    PLIST_TEMP="/tmp/sketchybar_pm.plist"
    sudo powermetrics -n 1 -i 1000 \
        --samplers cpu_power,gpu_power,thermal,tasks \
        --format plist > "$PLIST_TEMP" 2>/dev/null

    if [ -s "$PLIST_TEMP" ]; then
        # Convert to JSON
        plutil -convert json "$PLIST_TEMP" -o "$CACHE" 2>/dev/null
        cat "$CACHE"
    else
        echo "{}"
    fi
}

# Smoothing function (same as before)
smooth_value() {
    STAT=$1; VAL=$2; WIN=${3:-3}

    CURRENT_STATE=$(awk -F: -v s="$STAT" '$1==s {print $2}' "$STATE_FILE" 2>/dev/null)

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

    (grep -v "^$STAT:" "$STATE_FILE" 2>/dev/null || true; echo "$STAT:$VALS") > "$STATE_FILE.tmp"
    mv "$STATE_FILE.tmp" "$STATE_FILE"

    echo "$AVG"
}