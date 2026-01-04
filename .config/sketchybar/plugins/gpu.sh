#!/usr/bin/env sh

# GPU usage - direct reading from macmon
source "$HOME/.config/sketchybar/plugins/macmon_shared.sh"

GPU_PERCENT=""
MACMON_DATA=$(get_macmon_data)

if [ "$MACMON_DATA" != "{}" ]; then
    # Extract GPU usage ratio from gpu_usage array [frequency, ratio]
    GPU_RATIO=$(echo "$MACMON_DATA" | sed -n 's/.*"gpu_usage":\[[0-9]*,\([0-9]*\.[0-9]*\)\].*/\1/p')

    if [ -n "$GPU_RATIO" ]; then
        # Convert ratio to percentage (0.0-1.0 -> 0-100%)
        GPU_PERCENT=$(echo "$GPU_RATIO" | awk '{pct=$1*100; print (pct>100)?100:int(pct+0.5)}')
    fi
fi

# Fallback to 0% if no data
[ -z "$GPU_PERCENT" ] && GPU_PERCENT=0

# Colors (same thresholds as CPU for consistency)
if [ $GPU_PERCENT -lt 10 ]; then
    COLOR=0xff606060
elif [ $GPU_PERCENT -lt 25 ]; then
    COLOR=0xffFFFFFF
elif [ $GPU_PERCENT -lt 40 ]; then
    COLOR=0xffFFA500
else
    COLOR=0xffE74C3C
fi

sketchybar --set gpu label="${GPU_PERCENT}%" label.color=$COLOR icon.color=$COLOR