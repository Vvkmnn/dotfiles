#!/usr/bin/env sh

# Clock day part - kanagawa color
DAY=$(printf "%02d" $(date '+%-d'))

sketchybar --set clock_day label="$DAY"