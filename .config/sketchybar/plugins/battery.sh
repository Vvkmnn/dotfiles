#!/usr/bin/env sh

# Battery display - show true cycle count
PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

# Get battery cycle count - true value only
CYCLES=$(system_profiler SPPowerDataType 2>/dev/null | grep "Cycle Count" | awk '{print $3}')

# Only show cycles if we can actually read them
if [ -n "$CYCLES" ]; then
    # Format cycle count with spaces (3 digits, no leading zeros)
    CYCLES_FORMATTED=$(printf "%3d" $CYCLES)
    
    if [ -n "$CHARGING" ]; then
        # Plugged in - show cycle count
        ICON="[$CYCLES_FORMATTED]"
        COLOR=0xffDDB670 # Yellow when charging
    else
        # On battery - use bracket notation with fill level
        if [ $PERCENTAGE -gt 80 ]; then
            ICON="[|||]"     # Full
            COLOR=0xff606060 # Dim gray (normal)
        elif [ $PERCENTAGE -gt 60 ]; then
            ICON="[|| ]"     # 75%
            COLOR=0xff606060 # Dim gray (normal)
        elif [ $PERCENTAGE -gt 40 ]; then
            ICON="[|| ]"     # 50%
            COLOR=0xffFFFFFF # White (notable)
        elif [ $PERCENTAGE -gt 20 ]; then
            ICON="[|  ]"     # 25%
            COLOR=0xffDDB670 # Yellow (warning)
        else
            ICON="[   ]"     # Empty
            COLOR=0xffE74C3C # Red (critical)
        fi
    fi
else
    # Can't read cycles - show standard display
    if [ -n "$CHARGING" ]; then
        ICON="[+ -]"
        COLOR=0xffDDB670
    else
        ICON="[   ]"
        COLOR=0xff606060
    fi
fi

sketchybar --set battery icon="$ICON" \
	icon.color=$COLOR \
	label="${PERCENTAGE}%" \
	label.color=0xffFFFFFF