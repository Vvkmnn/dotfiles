#!/usr/bin/env sh

# Temperature - with smoothing
source "$HOME/.config/sketchybar/plugins/macmon_shared.sh"

TEMP="--"
MACMON_DATA=$(get_macmon_data)

if [ "$MACMON_DATA" != "{}" ]; then
    # Use CPU temperature
    RAW_TEMP=$(echo "$MACMON_DATA" | sed -n 's/.*"cpu_temp_avg":\([0-9]*\.[0-9]*\).*/\1/p' | cut -d. -f1)
    
    if [ -n "$RAW_TEMP" ] && [ "$RAW_TEMP" != "0" ]; then
        TEMP=$(smooth_value "temp" "$RAW_TEMP" 5)  # 5 samples for temperature
    fi
fi

# Final check
[ -z "$TEMP" ] || [ "$TEMP" = "0" ] && TEMP="--"

# Temperature ranges for fanless M3 Air
if [ "$TEMP" = "--" ]; then
    COLOR=0xff606060  # Dim gray
elif [ $TEMP -lt 65 ]; then
    COLOR=0xff606060  # Dim gray (cool)
elif [ $TEMP -lt 75 ]; then
    COLOR=0xffFFFFFF  # White (normal)
elif [ $TEMP -lt 85 ]; then
    COLOR=0xffFFA500  # Orange (warm)
else
    COLOR=0xffE74C3C  # Red (hot)
fi

sketchybar --set temp label="${TEMP}°" label.color=$COLOR icon.color=$COLOR
