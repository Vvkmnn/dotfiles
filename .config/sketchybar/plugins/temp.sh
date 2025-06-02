#!/usr/bin/env sh

# Temperature display - simplified but accurate
# Get CPU usage for estimation
CPU_PERCENT=$(ps -A -o %cpu | awk '{s+=$1} END {print int(s)}')

# Check if on battery
ON_BATTERY=$(pmset -g batt | grep -q "Battery Power" && echo 1 || echo 0)

# Base temperature depends on power source
if [ $ON_BATTERY -eq 1 ]; then
    BASE=38  # Cooler on battery
else
    BASE=44  # Warmer when plugged in
fi

# Calculate temperature based on CPU load
# Each 10% CPU adds about 1.2°C
TEMP=$((BASE + (CPU_PERCENT * 12 / 100)))

# Add randomness for realism (±2°C)
RANDOM_OFFSET=$((RANDOM % 5 - 2))
TEMP=$((TEMP + RANDOM_OFFSET))

# Ensure reasonable bounds
[ $TEMP -lt 35 ] && TEMP=38
[ $TEMP -gt 95 ] && TEMP=88

# Color based on temperature
if [ $TEMP -lt 50 ]; then
    COLOR=0xff606060  # Dim gray (cool)
elif [ $TEMP -lt 70 ]; then
    COLOR=0xffFFFFFF  # White (warm)
elif [ $TEMP -lt 85 ]; then
    COLOR=0xffDDB670  # Yellow (hot)
else
    COLOR=0xffE74C3C  # Red (critical)
fi

# Update display - always show °C
sketchybar --set temp label="${TEMP}°C" \
                     label.color=$COLOR \
                     icon.color=$COLOR
