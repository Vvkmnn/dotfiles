#!/usr/bin/env sh

CACHE="/tmp/sketchybar_powermetrics.plist"
STATE_FILE="/tmp/sketchybar_state"
CACHE_MAX_AGE=5

# Get powermetrics plist data (with 5s cache)
get_powermetrics_plist() {
    if [ -f "$CACHE" ]; then
        AGE=$(($(date +%s) - $(stat -f %m "$CACHE" 2>/dev/null || echo 0)))
        if [ $AGE -lt $CACHE_MAX_AGE ]; then
            cat "$CACHE"
            return
        fi
    fi

    # Call powermetrics (with sudo, no password needed)
    sudo /usr/bin/powermetrics -n 1 -i 1000 \
        --samplers cpu_power,gpu_power,thermal,tasks \
        --format plist > "$CACHE" 2>/dev/null

    if [ -s "$CACHE" ]; then
        cat "$CACHE"
    else
        echo '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict></dict></plist>'
    fi
}

# Extract combined power in milliwatts
get_power_mw() {
    PLIST=$(get_powermetrics_plist)
    echo "$PLIST" | grep -A 1 "<key>combined_power</key>" | tail -1 | sed 's/.*<real>\(.*\)<\/real>.*/\1/'
}

# Extract GPU usage as ratio (0.0-1.0)
get_gpu_ratio() {
    PLIST=$(get_powermetrics_plist)
    echo "$PLIST" | awk '/<key>gpu<\/key>/,/<\/dict>/ {print}' | grep -A 1 "used_ratio" | grep "<real>" | sed 's/.*<real>\(.*\)<\/real>.*/\1/'
}

# Extract thermal pressure status
get_thermal_pressure() {
    PLIST=$(get_powermetrics_plist)
    echo "$PLIST" | grep "<key>thermal_pressure</key>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/'
}

# Extract CPU power in milliwatts
get_cpu_power_mw() {
    PLIST=$(get_powermetrics_plist)
    echo "$PLIST" | grep -A 1 "<key>cpu_power</key>" | tail -1 | sed 's/.*<real>\(.*\)<\/real>.*/\1/'
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