#!/usr/bin/env sh

# Disk usage - consistent color scheme
USAGE=$(diskutil apfs list | grep "Capacity In Use By Volumes" | grep -o "[0-9.]*%" | sed 's/%//' | cut -d. -f1)

# Fallback if command fails
if [ -z "$USAGE" ]; then
    USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
fi

# Color scheme: dim gray -> white -> yellow -> red
if [ $USAGE -lt 60 ]; then
    COLOR=0xff606060  # Dim gray (normal)
elif [ $USAGE -lt 75 ]; then
    COLOR=0xffFFFFFF  # White (notable)
elif [ $USAGE -lt 85 ]; then
    COLOR=0xffDDB670  # Yellow (warning)
else
    COLOR=0xffE74C3C  # Red (critical)
fi

sketchybar --set disk label="${USAGE}%" \
                     label.color=$COLOR \
                     icon.color=$COLOR
