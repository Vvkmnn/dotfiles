#!/usr/bin/env sh

# Analog clock display using clock face Unicode characters
# Clock faces: 🕐🕑🕒🕓🕔🕕🕖🕗🕘🕙🕚🕛
# Half hours: 🕜🕝🕞🕟🕠🕡🕢🕣🕤🕥🕦🕧

HOUR=$(date '+%-I')  # 12-hour format without leading zero
MINUTE=$(date '+%-M')

# Calculate which clock face to show
# Each clock face represents 30 minutes (12 hours * 2 = 24 positions)
CLOCK_INDEX=$(( (HOUR % 12) * 2 ))

# Add 1 to index if we're past 30 minutes
if [ $MINUTE -ge 30 ]; then
    CLOCK_INDEX=$(( CLOCK_INDEX + 1 ))
fi

# Clock faces array (12:00 to 11:30)
CLOCKS=(🕐 🕜 🕑 🕝 🕒 🕞 🕓 🕟 🕔 🕠 🕕 🕡 🕖 🕢 🕗 🕣 🕘 🕤 🕙 🕥 🕚 🕦 🕛 🕧)

# Get the appropriate clock face
CLOCK_FACE=${CLOCKS[$CLOCK_INDEX]}

# Color based on time of day
HOUR24=$(date '+%-H')
if [ $HOUR24 -ge 6 ] && [ $HOUR24 -lt 12 ]; then
    # Morning - warm yellow
    COLOR=0xffDDB670
elif [ $HOUR24 -ge 12 ] && [ $HOUR24 -lt 18 ]; then
    # Afternoon - white
    COLOR=0xffFFFFFF
elif [ $HOUR24 -ge 18 ] && [ $HOUR24 -lt 22 ]; then
    # Evening - soft orange
    COLOR=0xffE8D0A0
else
    # Night - dim gray
    COLOR=0xff808080
fi

sketchybar --set clock_analog label="$CLOCK_FACE" \
                             label.color=$COLOR