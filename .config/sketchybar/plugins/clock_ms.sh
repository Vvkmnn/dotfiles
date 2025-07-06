#!/usr/bin/env sh

# Milliseconds - more efficient using date command
MS=$(date '+.%3N' 2>/dev/null || printf ".%03d" $(($(date +%s%3N) % 1000)))

sketchybar --set clock_ms label="$MS"
