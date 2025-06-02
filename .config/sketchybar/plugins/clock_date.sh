#!/usr/bin/env sh

# Clock date part - white
YEAR=$(date '+%Y')
MONTH=$(printf "%02d" $(date '+%-m'))
DAY=$(printf "%02d" $(date '+%-d'))

sketchybar --set clock_date label="$YEAR $MONTH $DAY"
