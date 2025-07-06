#!/usr/bin/env sh

# CPU usage - direct reading, no smoothing needed
source "$HOME/.config/sketchybar/plugins/macmon_shared.sh"

CPU_PERCENT=""
MACMON_DATA=$(get_macmon_data)

if [ "$MACMON_DATA" != "{}" ]; then
    ECPU=$(echo "$MACMON_DATA" | sed -n 's/.*"ecpu_usage":\[[0-9]*,\([0-9]*\.[0-9]*\)\].*/\1/p')
    PCPU=$(echo "$MACMON_DATA" | sed -n 's/.*"pcpu_usage":\[[0-9]*,\([0-9]*\.[0-9]*\)\].*/\1/p')
    
    if [ -n "$ECPU" ] && [ -n "$PCPU" ]; then
        CPU_PERCENT=$(echo "$ECPU $PCPU" | awk '{avg=($1+$2)/2*100; print (avg>100)?100:int(avg)}')
    fi
fi

# Fallback
[ -z "$CPU_PERCENT" ] && CPU_PERCENT=$(ps aux | awk '{sum += $3} END {s=int(sum); print (s>100)?100:s}')

# Colors
if [ $CPU_PERCENT -lt 10 ]; then
    COLOR=0xff606060
elif [ $CPU_PERCENT -lt 25 ]; then
    COLOR=0xffFFFFFF
elif [ $CPU_PERCENT -lt 40 ]; then
    COLOR=0xffFFA500
else
    COLOR=0xffE74C3C
fi

sketchybar --set cpu label="${CPU_PERCENT}%" label.color=$COLOR icon.color=$COLOR
