#!/bin/bash
# Wake/unlock fade-in: transparent → smooth fade in → start bar-daemon
# Triggered by system_woke (covers lid open, display wake, AND password unlock)

# Only run on actual wake event, not --update
[ "$SENDER" = "system_woke" ] || exit 0

# Skip if bar-daemon is already running (startup cascade handles initial boot)
pgrep -f "helpers/bar-daemon" >/dev/null && exit 0

PLUGIN_DIR="$HOME/.config/sketchybar/plugins"
source "$PLUGIN_DIR/bar_colors.sh"

# Disable space.sh during fade
sketchybar --set space_handler script=""

# Build dynamic space args for transparent and restore
SPACES=($(get_spaces))
SPACE_TRANSPARENT=""
SPACE_RESTORE=""
for s in "${SPACES[@]}"; do
  SPACE_TRANSPARENT="$SPACE_TRANSPARENT --set $s icon.color=$T_OLD_WHITE"
  SPACE_RESTORE="$SPACE_RESTORE --set $s icon.color=$K_OLD_WHITE"
done

# Set everything transparent, hide graphs
sketchybar \
  --set logo background.image.scale=0 \
  $SPACE_TRANSPARENT \
  --set location icon.color=$T_OLD_WHITE label.color=$T_OLD_WHITE \
  --set connection icon.color=$T_OLD_WHITE label.color=$T_OLD_WHITE \
  --set network_down icon.color=$T_DIM label.color=$T_DIM \
  --set graph_down drawing=off \
  --set network_up icon.color=$T_DIM label.color=$T_DIM \
  --set graph_up drawing=off \
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

sleep 0.8

# Restore graphs then fade everything in (~1.5s)
sketchybar --set graph_down drawing=on --set graph_up drawing=on
sketchybar --animate sin 90 \
  --set logo background.image.scale=0.048 \
  $SPACE_RESTORE \
  --set location icon.color=$K_OLD_WHITE label.color=$K_OLD_WHITE \
  --set connection icon.color=$K_OLD_WHITE label.color=$K_OLD_WHITE \
  --set network_down icon.color=$K_DIM label.color=$K_DIM \
  --set graph_down graph.color=$K_DIM graph.fill_color=$K_GRAPH_FILL \
  --set network_up icon.color=$K_DIM label.color=$K_DIM \
  --set graph_up graph.color=$K_DIM graph.fill_color=$K_GRAPH_FILL \
  --set progress_icon icon.color=$K_WHITE \
  --set progress icon.color=$K_OLD_WHITE label.color=$K_OLD_WHITE \
      slider.highlight_color=$K_WHITE slider.background.color=$K_DIM \
  --set clock_time label.color=$K_WHITE \
  --set battery icon.color=$K_WHITE label.color=$K_WHITE \
  --set disk icon.color=$K_DIM label.color=$K_DIM \
  --set memory icon.color=$K_DIM label.color=$K_DIM \
  --set cpu icon.color=$K_DIM label.color=$K_DIM \
  --set gpu icon.color=$K_DIM label.color=$K_DIM \
  --set power icon.color=$K_DIM label.color=$K_DIM \
  --set temp icon.color=$K_DIM label.color=$K_DIM

# Start bar-daemon (startupSmooth=true handles first updates)
"$HOME/.config/sketchybar/helpers/bar-daemon" &

# Re-enable space.sh
sketchybar --set space_handler script="$PLUGIN_DIR/space.sh"
sketchybar --update &
