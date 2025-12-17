#!/usr/bin/env sh

# Seconds with colon prefix (no trailing fractional part)
SEC=$(date '+:%S')

sketchybar --set clock_sec label="$SEC"
