#!/usr/bin/env sh

# Battery display with dynamic icons and unified color logic
PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

# Get battery cycle count
CYCLES=$(system_profiler SPPowerDataType 2>/dev/null | grep "Cycle Count" | awk '{print $3}')

# Determine battery icon based on percentage
if [ $PERCENTAGE -gt 60 ]; then
	BATT_ICON="􀛨 "  # battery.100
elif [ $PERCENTAGE -gt 30 ]; then
	BATT_ICON="􀛩 "  # battery.75
else
	BATT_ICON="􀛪 "  # battery.50
fi

# Determine display format
if [ -n "$CHARGING" ] && [ $PERCENTAGE -ge 80 ] && [ -n "$CYCLES" ]; then
	# Charging and healthy - show cycle count
	CYCLES_FORMATTED=$(printf "%3d" $CYCLES)
	ICON="${BATT_ICON}[$CYCLES_FORMATTED]"
else
	# Show percentage in all other cases
	ICON="${BATT_ICON}[${PERCENTAGE}%]"
fi

# Color based purely on percentage (matches other system icons)
if [ $PERCENTAGE -gt 30 ]; then
	COLOR=0xffFFFFFF  # White - normal
elif [ $PERCENTAGE -gt 10 ]; then
	COLOR=0xffFFA500  # Orange - warning
else
	COLOR=0xffE74C3C  # Red - critical
fi

sketchybar --set battery icon="$ICON" \
	icon.color=$COLOR \
	label="" \
	label.color=0xffFFFFFF
