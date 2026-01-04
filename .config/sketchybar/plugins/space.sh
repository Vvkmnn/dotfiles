#!/usr/bin/env sh

# Modern space indicator - dynamically handles unlimited spaces

# Modern colors
MISTY_BLUE=0xc0c0c0FF    # Misty blue for active space (fully opaque)
LIGHT_GRAY=0xffE0E0E0    # Light gray for spaces with windows
MID_GRAY=0xffA0A0A0      # Medium gray for normal
DIM_GRAY=0xff606060      # Dim gray for empty

# Get space info
SPACES_INFO=$(/opt/homebrew/bin/yabai -m query --spaces)
CURRENT=$(echo "$SPACES_INFO" | jq -r '.[] | select(.["has-focus"] == true) | .index')
ALL_SPACES=$(echo "$SPACES_INFO" | jq -r '.[].index')

# Update all spaces dynamically
for i in $ALL_SPACES; do
  WINDOWS=$(echo "$SPACES_INFO" | jq -r --arg space "$i" '.[] | select(.index == ($space | tonumber)) | .windows | length // 0')
  
  if [ "$i" = "$CURRENT" ]; then
    # Active space - silver text
    sketchybar --set space.$i \
      icon="$i" \
      icon.color=$MISTY_BLUE \
      icon.font="SF Pro:Medium:13.0" \
      icon.padding_left=0 \
      icon.padding_right=0 \
      label.drawing=off \
      background.drawing=off \
      width=20
  elif [ "$WINDOWS" -gt "0" ]; then
    # Space with windows - light text
    sketchybar --set space.$i \
      icon="$i" \
      icon.color=$LIGHT_GRAY \
      icon.font="SF Pro:Medium:13.0" \
      icon.padding_left=0 \
      icon.padding_right=0 \
      label.drawing=off \
      background.drawing=off \
      width=20
  else
    # Empty space - dimmed
    sketchybar --set space.$i \
      icon="$i" \
      icon.color=$DIM_GRAY \
      icon.font="SF Pro:Regular:13.0" \
      icon.padding_left=0 \
      icon.padding_right=0 \
      label.drawing=off \
      background.drawing=off \
      width=20
  fi
done
