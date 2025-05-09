#!/usr/bin/env sh

# Get memory usage percentage
MEM=$(memory_pressure | grep "System-wide memory free percentage" | awk '{ print 100-$NF }')
MEM_ROUNDED=$(printf "%.0f" $MEM)

# Update sketchybar
sketchybar --set $NAME label="${MEM_ROUNDED}%"

# Color code based on usage
if [[ $MEM_ROUNDED -gt 80 ]]; then
  sketchybar --set $NAME label.color=0xffbf616a
elif [[ $MEM_ROUNDED -gt 50 ]]; then
  sketchybar --set $NAME label.color=0xffebcb8b
else
  sketchybar --set $NAME label.color=0xffa3be8c
fi
