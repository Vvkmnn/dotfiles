#!/usr/bin/env sh

# Total system power - lightweight smoothing for volatile readings
source "$HOME/.config/sketchybar/plugins/macmon_shared.sh"

POWER_FILE="/tmp/sketchybar_power"
TOTAL_POWER="0"
MACMON_DATA=$(get_macmon_data)

if [ "$MACMON_DATA" != "{}" ]; then
    RAW_POWER=$(echo "$MACMON_DATA" | grep -o '"sys_power":[0-9.]*' | cut -d: -f2 | awk '{printf "%.0f", $1}')
    
    if [ -n "$RAW_POWER" ]; then
        # Show current power without averaging for real-time accuracy
        TOTAL_POWER="$RAW_POWER"
    fi
fi

# Colors
if [ "$TOTAL_POWER" -lt 5 ]; then
    COLOR=0xff606060
elif [ "$TOTAL_POWER" -lt 10 ]; then
    COLOR=0xffFFFFFF
elif [ "$TOTAL_POWER" -lt 15 ]; then
    COLOR=0xffFFA500
else
    COLOR=0xffE74C3C
fi

sketchybar --set power label="${TOTAL_POWER}W" label.color=$COLOR icon.color=$COLOR
