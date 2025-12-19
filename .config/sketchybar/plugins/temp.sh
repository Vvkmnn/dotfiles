#!/usr/bin/env sh

# Temperature - with enhanced smoothing and stability
source "$HOME/.config/sketchybar/plugins/macmon_shared.sh"

TEMP=""
MACMON_DATA=$(get_macmon_data)

if [ "$MACMON_DATA" != "{}" ]; then
    RAW_TEMP=$(echo "$MACMON_DATA" | jq -r '.temp.cpu_temp_avg // empty' 2>/dev/null)

    if [ -z "$RAW_TEMP" ]; then
        RAW_TEMP=$(echo "$MACMON_DATA" | sed -n 's/.*"cpu_temp_avg":\([0-9]*\.[0-9]*\).*/\1/p')
    fi

    if echo "$RAW_TEMP" | grep -Eq '^[0-9]+(\.[0-9]+)?$'; then
        RAW_TEMP_INT=$(awk -v t="$RAW_TEMP" 'BEGIN { printf "%d", int(t + 0.5) }')

        # Reject outliers outside plausible Celsius range
        if [ "$RAW_TEMP_INT" -ge 10 ] && [ "$RAW_TEMP_INT" -le 110 ]; then
            TEMP=$(smooth_value "temp" "$RAW_TEMP_INT" 3)
        fi
    fi
fi

# Final validation
if ! echo "$TEMP" | grep -Eq '^[0-9]+$'; then
    # keep previous smoothed value if available
    LAST=$(awk -F: '$1=="temp" {print $2}' "/tmp/sketchybar_state" 2>/dev/null | awk '{print $NF}')
    if echo "$LAST" | grep -Eq '^[0-9]+$'; then
        TEMP="$LAST"
    else
        exit 0
    fi
fi

# Temperature ranges tuned for Celsius values
if [ "$TEMP" -le 0 ]; then
    COLOR=0xff606060
elif [ "$TEMP" -lt 60 ]; then
    COLOR=0xffFFFFFF
elif [ "$TEMP" -lt 80 ]; then
    COLOR=0xffFFA500
else
    COLOR=0xffE74C3C  # Red (hot)
fi

sketchybar --set temp label="${TEMP}°" label.color=$COLOR icon.color=$COLOR
