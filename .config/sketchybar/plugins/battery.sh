#!/usr/bin/env sh

# Battery display - improved charging icon
PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [ -n "$CHARGING" ]; then
	# Plugged in - use + symbol for charging
	ICON="[+ -]"
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

sketchybar --set battery icon="$ICON" \
	icon.color=$COLOR \
	label="${PERCENTAGE}%" \
	label.color=$COLOR
