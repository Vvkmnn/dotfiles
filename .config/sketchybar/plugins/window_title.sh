#!/usr/bin/env sh

# Minimal window title display
WINDOW_INFO=$(/opt/homebrew/bin/yabai -m query --windows --window 2>/dev/null)

if [ -n "$WINDOW_INFO" ]; then
    APP=$(echo "$WINDOW_INFO" | jq -r '.app // empty')
    TITLE=$(echo "$WINDOW_INFO" | jq -r '.title // empty')
    
    if [ -n "$TITLE" ] && [ "$TITLE" != "null" ] && [ ${#TITLE} -gt 2 ]; then
        # Limit length
        if [ ${#TITLE} -gt 40 ]; then
            DISPLAY_TITLE="${TITLE:0:37}..."
        else
            DISPLAY_TITLE="$TITLE"
        fi
        sketchybar --set window_title label="$DISPLAY_TITLE"
    elif [ -n "$APP" ] && [ "$APP" != "null" ]; then
        sketchybar --set window_title label="$APP"
    else
        sketchybar --set window_title label=""
    fi
else
    sketchybar --set window_title label=""
fi
