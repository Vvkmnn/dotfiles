#!/usr/bin/env sh

# Custom analog clock using drawing characters (no emojis)
HOUR=$(date '+%-I')  # 12-hour format
MINUTE=$(date '+%-M')

# Calculate angle for clock hands
# Hour hand: 30° per hour + 0.5° per minute
HOUR_ANGLE=$((HOUR * 30 + MINUTE / 2))
# Minute hand: 6° per minute
MIN_ANGLE=$((MINUTE * 6))

# Simple ASCII representation based on angles
# Using box drawing characters for a minimal look
if [ $MIN_ANGLE -lt 90 ]; then
    CLOCK="╱"  # Northeast
elif [ $MIN_ANGLE -lt 180 ]; then
    CLOCK="─"  # East
elif [ $MIN_ANGLE -lt 270 ]; then
    CLOCK="╲"  # Southeast
else
    CLOCK="│"  # South/North
fi

# Add hour indicator
if [ $HOUR_ANGLE -lt 90 ] || [ $HOUR_ANGLE -ge 270 ]; then
    CLOCK="◐${CLOCK}"  # Morning/Night
else
    CLOCK="◑${CLOCK}"  # Afternoon/Evening
fi

# Time of day coloring - silver tones
HOUR24=$(date '+%-H')
if [ $HOUR24 -ge 6 ] && [ $HOUR24 -lt 12 ]; then
    COLOR=0xffE0E0E0  # Light silver (morning)
elif [ $HOUR24 -ge 12 ] && [ $HOUR24 -lt 18 ]; then
    COLOR=0xffFFFFFF  # White (afternoon)
elif [ $HOUR24 -ge 18 ] && [ $HOUR24 -lt 22 ]; then
    COLOR=0xffC0C0C0  # Silver (evening)
else
    COLOR=0xff808080  # Dark silver (night)
fi

sketchybar --set clock_analog label="$CLOCK" \
                             label.color=$COLOR \
                             label.font="SFMono Nerd Font:Regular:13.0"
