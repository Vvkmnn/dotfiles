#!/usr/bin/env sh

# Minutes with colon prefix
MIN=$(date '+:%M')

sketchybar --set clock_min label="$MIN"
