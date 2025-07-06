#!/usr/bin/env sh

# Clock month part
MONTH=$(printf "%02d" $(date '+%-m'))

sketchybar --set clock_month label="$MONTH"