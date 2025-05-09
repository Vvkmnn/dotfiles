#!/usr/bin/env sh

YABAI_SPACES=$(yabai -m query --spaces)
SPACE=$(echo $YABAI_SPACES | jq -r ".[] | select(.id == $SID)")
YABAI_WINDOW_COUNT=$(echo $SPACE | jq '.windows | length')
YABAI_IS_ACTIVE=$(echo $SPACE | jq '."has-focus"')

if [[ $YABAI_IS_ACTIVE == "true" ]]; then
  sketchybar --set $NAME background.color=0xff81a1c1 icon.highlight=on
else
  sketchybar --set $NAME background.color=0x803c3e4f icon.highlight=off
fi

# Show window count indicator if there are windows
if [[ $YABAI_WINDOW_COUNT -gt 0 ]]; then
  sketchybar --set $NAME icon.color=0xffffffff
else
  sketchybar --set $NAME icon.color=0xaa999999
fi
