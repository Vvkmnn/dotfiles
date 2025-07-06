#!/usr/bin/env sh

# Day of week (1-7, Monday=1)
DOW=$(date '+%u')

sketchybar --set clock_dow label="$DOW"
