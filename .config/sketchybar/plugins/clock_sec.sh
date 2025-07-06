#!/usr/bin/env sh

# Seconds with colon prefix
SEC=$(date '+:%S')

sketchybar --set clock_sec label="$SEC"
