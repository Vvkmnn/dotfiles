#!/usr/bin/env sh

CURRENT_SPACE=$(yabai -m query --spaces --space | jq -r '.index')
SPACE_TYPE=$(yabai -m query --spaces --space | jq -r '.type')

case $SPACE_TYPE in
  "bsp") sketchybar --set $NAME label="bsp" icon=﩯 icon.color=0xff8fbcbb ;;
  "stack") sketchybar --set $NAME label="stack" icon= icon.color=0xffa3be8c ;;
  "float") sketchybar --set $NAME label="float" icon=⭕ icon.color=0xffebcb8b ;;
  *) sketchybar --set $NAME label="$SPACE_TYPE" ;;
esac
