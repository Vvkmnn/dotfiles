#!/usr/bin/env sh

CPU=$(top -l 1 | grep -E "^CPU" | grep -Eo '[^[:space:]]+%' | head -1 | sed 's/\%//')

# Update the CPU usage bar
sketchybar --set $NAME label="${CPU}%"

# Color code based on usage
if [[ $CPU -gt 70 ]]; then
  sketchybar --set $NAME label.color=0xffbf616a
elif [[ $CPU -gt 40 ]]; then
  sketchybar --set $NAME label.color=0xffebcb8b
else
  sketchybar --set $NAME label.color=0xffa3be8c
fi
