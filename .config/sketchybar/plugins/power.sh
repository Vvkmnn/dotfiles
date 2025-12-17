#!/usr/bin/env sh

# Total system power - lightweight smoothing for volatile readings
source "$HOME/.config/sketchybar/plugins/macmon_shared.sh"

POWER_FILE="/tmp/sketchybar_power"
STATE_KEY="power_w10"
TOTAL_POWER=""
MACMON_DATA=$(get_macmon_data)

if [ "$MACMON_DATA" != "{}" ]; then
    RAW_POWER=$(echo "$MACMON_DATA" | jq -r '.all_power // empty' 2>/dev/null)

    if [ -z "$RAW_POWER" ]; then
        RAW_POWER=$(echo "$MACMON_DATA" | sed -n 's/.*"all_power":\([0-9]*\.[0-9]*\).*/\1/p')
    fi

    if echo "$RAW_POWER" | grep -Eq '^[0-9]+(\.[0-9]+)?$'; then
        if awk -v p="$RAW_POWER" 'BEGIN { exit !(p >= 0 && p <= 100) }'; then
            RAW_POWER_TENTHS=$(awk -v p="$RAW_POWER" 'BEGIN { printf "%d", int(p*10 + 0.5) }')
            SMOOTH_TENTHS=$(smooth_value "$STATE_KEY" "$RAW_POWER_TENTHS" 6)
            TOTAL_POWER=$(awk -v t="$SMOOTH_TENTHS" 'BEGIN { printf "%.1f", t/10.0 }')
        fi
    fi
fi

# Fallback to previous smoothed reading if current sample missing
if ! echo "$TOTAL_POWER" | grep -Eq '^[0-9]+(\.[0-9]+)?$'; then
    LAST=$(awk -F: -v s="$STATE_KEY" '$1==s {print $2}' "/tmp/sketchybar_state" 2>/dev/null | awk '{print $NF}')
    if echo "$LAST" | grep -Eq '^[0-9]+$'; then
        TOTAL_POWER=$(awk -v t="$LAST" 'BEGIN { printf "%.1f", t/10.0 }')
    else
        exit 0
    fi
fi

# Colors with realistic wattage tiers
if awk -v p="$TOTAL_POWER" 'BEGIN { exit !(p < 8) }'; then
    COLOR=0xffFFFFFF
elif awk -v p="$TOTAL_POWER" 'BEGIN { exit !(p < 15) }'; then
    COLOR=0xffFFA500
elif awk -v p="$TOTAL_POWER" 'BEGIN { exit !(p < 25) }'; then
    COLOR=0xffFF6F61
else
    COLOR=0xffE74C3C
fi

sketchybar --set power label="${TOTAL_POWER}W" label.color=$COLOR icon.color=$COLOR
