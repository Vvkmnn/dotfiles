#!/usr/bin/env sh

# Week of year
WEEK=$(date '+%V')

sketchybar --set clock_week label="$WEEK"
