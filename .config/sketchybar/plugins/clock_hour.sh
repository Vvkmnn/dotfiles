#!/usr/bin/env sh

# Hour component with zero padding
HOUR=$(date '+%H')

sketchybar --set clock_hour label="$HOUR"
