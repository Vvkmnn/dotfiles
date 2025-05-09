#!/usr/bin/env sh

BATTERY_PERCENTAGE=$(pmset -g batt | grep -Eo '\d+%' | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [[ $CHARGING != "" ]]; then
  case $BATTERY_PERCENTAGE in
    100) ICON= ;;
    9[0-9]) ICON= ;;
    8[0-9]) ICON= ;;
    7[0-9]) ICON= ;;
    6[0-9]) ICON= ;;
    5[0-9]) ICON= ;;
    4[0-9]) ICON= ;;
    3[0-9]) ICON= ;;
    2[0-9]) ICON= ;;
    1[0-9]) ICON= ;;
    *) ICON= ;;
  esac
  sketchybar --set $NAME icon=$ICON label="${BATTERY_PERCENTAGE}%" icon.color=0xffa3be8c
else
  case $BATTERY_PERCENTAGE in
    100) ICON= ;;
    9[0-9]) ICON= ;;
    8[0-9]) ICON= ;;
    7[0-9]) ICON= ;;
    6[0-9]) ICON= ;;
    5[0-9]) ICON= ;;
    4[0-9]) ICON= ;;
    3[0-9]) ICON= ;;
    2[0-9]) ICON= ;;
    1[0-9]) ICON= ;;
    *) ICON= ;;
  esac
  
  # Color based on battery percentage when not charging
  if [[ $BATTERY_PERCENTAGE -lt 20 ]]; then
    sketchybar --set $NAME icon=$ICON label="${BATTERY_PERCENTAGE}%" icon.color=0xffbf616a label.color=0xffbf616a
  elif [[ $BATTERY_PERCENTAGE -lt 40 ]]; then
    sketchybar --set $NAME icon=$ICON label="${BATTERY_PERCENTAGE}%" icon.color=0xffebcb8b label.color=0xffebcb8b
  else
    sketchybar --set $NAME icon=$ICON label="${BATTERY_PERCENTAGE}%" icon.color=0xffa3be8c
  fi
fi
