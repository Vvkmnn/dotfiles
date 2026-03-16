#!/usr/bin/env sh

# Space indicator — optimized: 1 yabai + 1 jq + 1 sketchybar per event
# (Was: 1 yabai + N+2 jq + N sketchybar = ~50-100 subprocesses with N space items)
# Font set once in sketchybarrc — not here (font names with spaces break unquoted $ARGS expansion)

ACTIVE_RED=0xffE74C3C
LAST_ORANGE=0xffFFA500
LIGHT_GRAY=0xffE0E0E0
DIM_GRAY=0xff606060

CURRENT_FILE="/tmp/sketchybar_current_space"
LAST_FILE="/tmp/sketchybar_last_space"

# Single yabai query
SPACES_INFO=$(/opt/homebrew/bin/yabai -m query --spaces 2>/dev/null) || exit 0

# Single jq call: extract index, focus, window count per space
SPACE_DATA=$(echo "$SPACES_INFO" | jq -r '.[] | "\(.index) \(."has-focus") \(.windows | length)"' 2>/dev/null) || exit 0

# Find current space from parsed data
CURRENT=""
while IFS=' ' read -r idx focus wcount; do
  [ "$focus" = "true" ] && CURRENT="$idx" && break
done <<EOF
$SPACE_DATA
EOF

# Track last space: CURRENT_FILE has current, LAST_FILE has previous
# Only update on space_change (not space_windows_change, which would clobber LAST)
if [ "$SENDER" = "space_change" ] || [ -z "$SENDER" ]; then
  PREV=$(cat "$CURRENT_FILE" 2>/dev/null)
  if [ -n "$PREV" ] && [ "$PREV" != "$CURRENT" ]; then
    echo "$PREV" > "$LAST_FILE"
  fi
  [ -n "$CURRENT" ] && echo "$CURRENT" > "$CURRENT_FILE"
fi
LAST=$(cat "$LAST_FILE" 2>/dev/null)

# Build single batched sketchybar command
ARGS=""
while IFS=' ' read -r idx focus wcount; do
  [ -z "$idx" ] && continue

  if [ "$idx" = "$CURRENT" ]; then
    COLOR=$ACTIVE_RED
  elif [ "$idx" = "$LAST" ] && [ -n "$LAST" ]; then
    COLOR=$LAST_ORANGE
  elif [ "$wcount" -gt 0 ] 2>/dev/null; then
    COLOR=$LIGHT_GRAY
  else
    COLOR=$DIM_GRAY
  fi

  ARGS="$ARGS --set space.$idx icon=$idx icon.color=$COLOR"
  ARGS="$ARGS icon.padding_left=0 icon.padding_right=0"
  ARGS="$ARGS label.drawing=off background.drawing=off width=20"
done <<EOF
$SPACE_DATA
EOF

# Single sketchybar IPC call for all spaces
[ -n "$ARGS" ] && sketchybar $ARGS
