#!/usr/bin/env sh

# Clock time part - always white
TIME=$(date '+%H:%M:%S')
MILLIS=$(perl -MTime::HiRes=time -e 'printf "%.3f", time' | cut -d. -f2)

# Always white color for time
COLOR=0xffFFFFFF

sketchybar --set clock_time label="$TIME.$MILLIS" \
                            label.color=$COLOR
