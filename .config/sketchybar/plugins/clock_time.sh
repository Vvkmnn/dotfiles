#!/usr/bin/env sh

# Clock time part - white with kanagawa flash
TIME=$(date '+%H:%M:%S')
MILLIS=$(perl -MTime::HiRes=time -e 'printf "%.3f", time' | cut -d. -f2)
SECONDS=$(date '+%S')

# Flash Kanagawa color for 1 second at the start of each minute
if [ "$SECONDS" = "00" ]; then
    COLOR=0xffDDB670  # Kanagawa off-white flash
else
    COLOR=0xffFFFFFF  # White normally
fi

sketchybar --set clock_time label="$TIME.$MILLIS" \
                            label.color=$COLOR
