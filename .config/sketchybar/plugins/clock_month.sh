#!/usr/bin/env sh

# Clock month part - middle gradient color
MONTH=$(printf "%02d" $(date '+%-m'))

sketchybar --set clock_month label="$MONTH"