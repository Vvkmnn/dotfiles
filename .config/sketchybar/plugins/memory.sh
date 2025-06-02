#!/usr/bin/env sh

# Memory usage - using memory_pressure for accuracy
MEMORY=$(memory_pressure | grep "System-wide memory free percentage:" | awk '{print 100-$5}')
MEMORY=${MEMORY%.*}

# Color scheme: dim gray -> white -> yellow -> red
if [ $MEMORY -lt 60 ]; then
    COLOR=0xff606060  # Dim gray (normal, not important)
elif [ $MEMORY -lt 75 ]; then
    COLOR=0xffFFFFFF  # White (notable)
elif [ $MEMORY -lt 85 ]; then
    COLOR=0xffDDB670  # Yellow (warning)
else
    COLOR=0xffE74C3C  # Red (critical)
fi

sketchybar --set memory label="${MEMORY}%" \
                       label.color=$COLOR \
                       icon.color=$COLOR
