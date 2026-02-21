#!/usr/bin/env sh

# Modern space indicator - dynamically handles unlimited spaces

# Colors (matched to network_stats.sh color scheme)
ACTIVE_RED=0xffE74C3C    # Red for active space - matches network high traffic
LAST_ORANGE=0xffFFA500   # Orange for last space - matches network medium traffic
LIGHT_GRAY=0xffE0E0E0    # Light gray for spaces with windows
DIM_GRAY=0xff606060      # Dim gray for empty

# State files for tracking spaces
STATE_DIR="/tmp/sketchybar_space_state"
LOCK_DIR="/tmp/sketchybar_space.lock"

# Get space info
SPACES_INFO=$(/opt/homebrew/bin/yabai -m query --spaces)
CURRENT=$(echo "$SPACES_INFO" | jq -r '.[] | select(.["has-focus"] == true) | .index')
ALL_SPACES=$(echo "$SPACES_INFO" | jq -r '.[].index')

# Ensure state dir exists
mkdir -p "$STATE_DIR"

# Only update state on space_change event (not space_windows_change)
if [ "$SENDER" = "space_change" ] || [ -z "$SENDER" ]; then
  if mkdir "$LOCK_DIR" 2>/dev/null; then
    # Read previous current → becomes last
    OLD_CURRENT=$(cat "$STATE_DIR/current" 2>/dev/null)
    # Write last (for all instances to read)
    [ -n "$OLD_CURRENT" ] && echo "$OLD_CURRENT" > "$STATE_DIR/last"
    # Write new current
    echo "$CURRENT" > "$STATE_DIR/current"
    # Clean up lock after delay
    (sleep 0.2; rmdir "$LOCK_DIR" 2>/dev/null) &
  fi
fi

# All instances read LAST from stable file
LAST=$(cat "$STATE_DIR/last" 2>/dev/null)

# Update all spaces dynamically
for i in $ALL_SPACES; do
  WINDOWS=$(echo "$SPACES_INFO" | jq -r --arg space "$i" '.[] | select(.index == ($space | tonumber)) | .windows | length // 0')

  if [ "$i" = "$CURRENT" ]; then
    # Active space - red
    sketchybar --set space.$i \
      icon="$i" \
      icon.color=$ACTIVE_RED \
      icon.font="SF Pro:Bold:13.0" \
      icon.padding_left=0 \
      icon.padding_right=0 \
      label.drawing=off \
      background.drawing=off \
      width=20
  elif [ "$i" = "$LAST" ] && [ -n "$LAST" ]; then
    # Last space (where you came from) - orange
    sketchybar --set space.$i \
      icon="$i" \
      icon.color=$LAST_ORANGE \
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
