#!/usr/bin/env sh

# Clock day part
DAY=$(printf "%02d" $(date '+%-d'))

sketchybar --set clock_day label="$DAY"