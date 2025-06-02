#!/usr/bin/env sh

# Modern front app display - white color
if [ "$SENDER" = "front_app_switched" ]; then
    sketchybar --set $NAME label="$INFO" \
                          label.color=0xffFFFFFF  # White
fi
