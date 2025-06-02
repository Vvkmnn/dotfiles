#!/usr/bin/env sh

# Clock week/dow part - dimmed
WEEK=$(date '+%V')
DOW=$(date '+%u')

sketchybar --set clock_week label="$WEEK $DOW"
