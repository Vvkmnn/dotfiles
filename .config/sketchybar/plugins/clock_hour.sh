#!/usr/bin/env sh

# Hour without separator
HOUR=$(date '+%-H')

sketchybar --set clock_hour label="$HOUR"
