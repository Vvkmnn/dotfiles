#!/usr/bin/env sh

# CPU usage - accurate and responsive
TOP_OUTPUT=$(top -l 2 -n 0 -s 0 | grep "CPU usage" | tail -1)
USER=$(echo "$TOP_OUTPUT" | awk '{print $3}' | sed 's/%//')
SYS=$(echo "$TOP_OUTPUT" | awk '{print $5}' | sed 's/%//')

# Calculate total CPU usage
CPU_TOTAL=$(awk "BEGIN {printf \"%.0f\", $USER + $SYS}")

# Color scheme: dim gray -> white -> yellow -> red
if [ $CPU_TOTAL -lt 30 ]; then
    COLOR=0xff606060  # Dim gray (normal)
elif [ $CPU_TOTAL -lt 60 ]; then
    COLOR=0xffFFFFFF  # White (notable)
elif [ $CPU_TOTAL -lt 80 ]; then
    COLOR=0xffDDB670  # Yellow (warning)
else
    COLOR=0xffE74C3C  # Red (critical)
fi

sketchybar --set cpu label="${CPU_TOTAL}%" \
                    label.color=$COLOR \
                    icon.color=$COLOR
