#!/usr/bin/env sh

# Disk usage - with smoothing for consistency
source "$HOME/.config/sketchybar/plugins/macmon_shared.sh"

# Get current disk usage
# APFS container % — reflects all volumes (system + data + swap) sharing the pool
# This is the number that determines when macOS starts struggling (~85%+)
RAW_USAGE=$(diskutil apfs list 2>/dev/null | grep "Capacity In Use By Volumes" | head -1 | sed -n 's/.*(\([0-9]*\.[0-9]*\)%.*/\1/p' | cut -d. -f1)

if [ -z "$RAW_USAGE" ]; then
    RAW_USAGE=$(df -h /System/Volumes/Data 2>/dev/null | awk 'NR==2 {print $5}' | sed 's/%//')
fi

# Smooth it (10 samples since disk changes slowly)
USAGE=$(smooth_value "disk" "$RAW_USAGE" 10)

# Color thresholds
if [ $USAGE -lt 30 ]; then
    COLOR=0xff606060  # Dim gray
elif [ $USAGE -lt 60 ]; then
    COLOR=0xffFFFFFF  # White
elif [ $USAGE -lt 80 ]; then
    COLOR=0xffFFA500  # Orange
else
    COLOR=0xffE74C3C  # Red
fi

sketchybar --set disk label="${USAGE}%" label.color=$COLOR icon.color=$COLOR
