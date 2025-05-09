#!/usr/bin/env sh

# Format: Day, Month Date, Time
CLOCK=$(date +"%a, %b %d, %H:%M")

sketchybar --set $NAME label="$CLOCK"
