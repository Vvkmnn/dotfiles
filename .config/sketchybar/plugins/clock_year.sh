#!/usr/bin/env sh

# Clock year part - only update the label, not the icon
YEAR=$(date '+%Y')

# Only update the label, keep the analog clock icon from config
sketchybar --set clock_year label="$YEAR"