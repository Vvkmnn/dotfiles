#!/bin/bash
# Lock/sleep fade-out: kill daemon, disable space.sh, fade all items to transparent
# Triggered by com.apple.screenIsLocked and system_will_sleep

# Only run on actual lock/sleep events, not on --update
[ "$SENDER" = "lock" ] || [ "$SENDER" = "system_will_sleep" ] || exit 0

PLUGIN_DIR="$HOME/.config/sketchybar/plugins"
source "$PLUGIN_DIR/bar_colors.sh"

# Kill daemon first so it doesn't fight the fade
pkill -f "helpers/bar-daemon" 2>/dev/null
pkill -f "macmon pipe" 2>/dev/null

# Disable space.sh (typing triggers space_windows_change)
sketchybar --set space_handler script=""

# Build dynamic space args
SPACE_FADE=""
for s in $(get_spaces); do
  SPACE_FADE="$SPACE_FADE --set $s icon.color=$T_OLD_WHITE"
done

# Fast fade — sin 20 = ~0.33s, safe before display cuts on lid close
sketchybar --animate sin 20 \
  --set logo background.image.scale=0 \
  $SPACE_FADE \
  --set location icon.color=$T_OLD_WHITE label.color=$T_OLD_WHITE \
  --set connection icon.color=$T_OLD_WHITE label.color=$T_OLD_WHITE \
  --set network_down icon.color=$T_DIM label.color=$T_DIM \
  --set graph_down graph.color=$T_DIM graph.fill_color=$T_DIM \
  --set network_up icon.color=$T_DIM label.color=$T_DIM \
  --set graph_up graph.color=$T_DIM graph.fill_color=$T_DIM \
  --set progress_icon icon.color=$T_WHITE \
  --set progress icon.color=$T_OLD_WHITE label.color=$T_OLD_WHITE \
      slider.highlight_color=$T_WHITE slider.background.color=$T_DIM \
  --set clock_time label.color=$T_WHITE \
  --set battery icon.color=$T_WHITE label.color=$T_WHITE \
  --set disk icon.color=$T_DIM label.color=$T_DIM \
  --set memory icon.color=$T_DIM label.color=$T_DIM \
  --set cpu icon.color=$T_DIM label.color=$T_DIM \
  --set gpu icon.color=$T_DIM label.color=$T_DIM \
  --set power icon.color=$T_DIM label.color=$T_DIM \
  --set temp icon.color=$T_DIM label.color=$T_DIM

# Hide graphs after fade
sleep 0.4
sketchybar --set graph_down drawing=off --set graph_up drawing=off
