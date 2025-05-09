#!/usr/bin/env bash
#disk.sh

PERCENTAGE=$(df -H /System/Volumes/Data | awk 'NR==2 {print $5}')
sketchybar -m --set "$NAME" label="${PERCENTAGE} "
