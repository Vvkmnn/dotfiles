#!/usr/bin/env sh

# Battery display with dynamic icons, cycle count, and unified color logic
# Single ioreg call replaces pmset + ioreg + system_profiler (3 tools → 1)
BATT_DATA=$(ioreg -rn AppleSmartBattery)
# Top-level fields use " = " format (BatteryData inner fields use "=" without spaces)
PERCENTAGE=$(echo "$BATT_DATA" | awk '/"CurrentCapacity" =/{c=$NF} /"MaxCapacity" =/{m=$NF} END{if(m>0) printf "%d", (c*100/m); else print 0}')
# ExternalConnected reliable even with BatFi; FedExternalConnected reports phantom MagSafe
POWER_CONNECTED=$(echo "$BATT_DATA" | grep -q '"ExternalConnected" = Yes' && echo "yes")

# Determine battery icon based on percentage, with charging override
# Old SF Symbol icons: charging=􀢋, 100=􀛨, 75=􀛩, 50=􀛪
if [ -n "$POWER_CONNECTED" ]; then
	BATT_ICON="󰚥"  # nf-md-battery_charging_40
elif [ $PERCENTAGE -gt 80 ]; then
	BATT_ICON="󰁹"  # nf-md-battery (full)
elif [ $PERCENTAGE -gt 60 ]; then
	BATT_ICON="󰂁"  # nf-md-battery_80
elif [ $PERCENTAGE -gt 40 ]; then
	BATT_ICON="󰁿"  # nf-md-battery_60
elif [ $PERCENTAGE -gt 20 ]; then
	BATT_ICON="󰁽"  # nf-md-battery_40
elif [ $PERCENTAGE -gt 10 ]; then
	BATT_ICON="󰁻"  # nf-md-battery_20
else
	BATT_ICON="󰂃"  # nf-md-battery_alert
fi

# Plugged in + ≥80% → cycles with dimming (full state)
if [ -n "$POWER_CONNECTED" ] && [ "$PERCENTAGE" -ge 80 ]; then
	CYCLE_COUNT=$(echo "$BATT_DATA" | awk '/"CycleCount" =/{print $NF}')
	DISPLAY="${CYCLE_COUNT}"
	COLOR=0xff606060  # DIM_GRAY - fades into background
else
	# Everything else shows percentage with warning colors
	DISPLAY="${PERCENTAGE}%"
	if [ "$PERCENTAGE" -gt 30 ]; then
		COLOR=0xffFFFFFF  # White - normal
	elif [ "$PERCENTAGE" -gt 10 ]; then
		COLOR=0xffFFA500  # Orange - warning
	else
		COLOR=0xffE74C3C  # Red - critical
	fi
fi

sketchybar --set battery icon="$BATT_ICON" \
	icon.color=$COLOR \
	label="$DISPLAY" \
	label.color=$COLOR
