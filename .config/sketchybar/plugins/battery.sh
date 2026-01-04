#!/usr/bin/env sh

# Battery display with dynamic icons and unified color logic
PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

# Determine battery icon based on percentage, with charging override
if [ -n "$CHARGING" ]; then
	BATT_ICON="􀢋 "  # battery.bolt (charging)
elif [ $PERCENTAGE -gt 60 ]; then
	BATT_ICON="􀛨 "  # battery.100
elif [ $PERCENTAGE -gt 30 ]; then
	BATT_ICON="􀛩 "  # battery.75
else
	BATT_ICON="􀛪 "  # battery.50
fi

# Show percentage in all cases
ICON="${BATT_ICON}[${PERCENTAGE}%]"

# Color logic based on percentage
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
