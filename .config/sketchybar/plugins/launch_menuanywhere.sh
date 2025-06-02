#!/bin/bash
# Launch menuanywhere

# First try the new compiled version
if [ -f "$HOME/.config/sketchybar/plugins/menuanywhere_new" ]; then
    $HOME/.config/sketchybar/plugins/menuanywhere_new &
elif [ -f "$HOME/.config/sketchybar/plugins/menuanywhere" ]; then
    $HOME/.config/sketchybar/plugins/menuanywhere &
else
    echo "MenuAnywhere not found"
fi
