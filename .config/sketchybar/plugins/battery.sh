#!/usr/bin/env sh

# Battery display with dynamic icons, cycle count, and unified color logic
PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
# Check power connection via ExternalConnected (reliable even with BatFi)
# FedExternalConnected is unreliable - reports phantom MagSafe state
POWER_CONNECTED=$(ioreg -rn AppleSmartBattery | grep -q '"ExternalConnected" = Yes' && echo "yes")
CYCLE_COUNT=$(system_profiler SPPowerDataType | grep "Cycle Count" | awk '{print $3}')

# Determine battery icon based on percentage, with charging override
if [ -n "$POWER_CONNECTED" ]; then
	BATT_ICON="􀢋 "  # battery.bolt (charging)
elif [ $PERCENTAGE -gt 60 ]; then
	BATT_ICON="􀛨 "  # battery.100
elif [ $PERCENTAGE -gt 30 ]; then
	BATT_ICON="􀛩 "  # battery.75
else
	BATT_ICON="􀛪 "  # battery.50
fi

# Plugged in + ≥80% → cycles with dimming (full state)
if [ -n "$POWER_CONNECTED" ] && [ "$PERCENTAGE" -ge 80 ]; then
	DISPLAY="[${CYCLE_COUNT}]"
	COLOR=0xff606060  # DIM_GRAY - fades into background
else
	# Everything else shows percentage with warning colors
	DISPLAY="[${PERCENTAGE}%]"
	if [ "$PERCENTAGE" -gt 30 ]; then
		COLOR=0xffFFFFFF  # White - normal
	elif [ "$PERCENTAGE" -gt 10 ]; then
		COLOR=0xffFFA500  # Orange - warning
	else
		COLOR=0xffE74C3C  # Red - critical
	fi
fi

ICON="${BATT_ICON}${DISPLAY}"

sketchybar --set battery icon="$ICON" \
	icon.color=$COLOR \
	label="" \
	label.color=0xffFFFFFF
