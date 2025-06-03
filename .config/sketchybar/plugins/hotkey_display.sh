#!/usr/bin/env sh

# Display last hotkey - read from temp file
HOTKEY_FILE="/tmp/sketchybar_last_hotkey"

if [ -f "$HOTKEY_FILE" ]; then
    LAST_HOTKEY=$(cat "$HOTKEY_FILE")
    sketchybar --set menuanywhere label="$LAST_HOTKEY"
else
    sketchybar --set menuanywhere label="⌥M"
fi