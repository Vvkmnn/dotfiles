#!/usr/bin/env sh

# Memory usage - with smoothing
source "$HOME/.config/sketchybar/plugins/macmon_shared.sh"

MEMORY_PERCENT=""
MACMON_DATA=$(get_macmon_data)

if [ "$MACMON_DATA" != "{}" ]; then
    RAM_USAGE=$(echo "$MACMON_DATA" | sed -n 's/.*"ram_usage":\([0-9]*\).*/\1/p')
    RAM_TOTAL=$(echo "$MACMON_DATA" | sed -n 's/.*"ram_total":\([0-9]*\).*/\1/p')
    
    if [ -n "$RAM_USAGE" ] && [ -n "$RAM_TOTAL" ] && [ "$RAM_TOTAL" -gt 0 ]; then
        RAW_MEM=$(awk "BEGIN {printf \"%.0f\", ($RAM_USAGE/$RAM_TOTAL)*100}")
        MEMORY_PERCENT=$(smooth_value "memory" "$RAW_MEM" 3)
    fi
fi

# Fallback
if [ -z "$MEMORY_PERCENT" ]; then
    RAW_MEM=$(memory_pressure | grep "System-wide memory free percentage:" | awk '{printf "%.0f", 100-$5}')
    MEMORY_PERCENT=$(smooth_value "memory" "$RAW_MEM" 3)
fi

# Thresholds for 16GB M3 Air
if [ $MEMORY_PERCENT -lt 50 ]; then
    COLOR=0xff606060  # Dim gray
elif [ $MEMORY_PERCENT -lt 70 ]; then
    COLOR=0xffFFFFFF  # White
elif [ $MEMORY_PERCENT -lt 80 ]; then
    COLOR=0xffFFA500  # Orange
else
    COLOR=0xffE74C3C  # Red
fi

sketchybar --set memory label="${MEMORY_PERCENT}%" label.color=$COLOR icon.color=$COLOR
