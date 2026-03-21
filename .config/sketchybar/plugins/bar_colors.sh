#!/bin/bash
# Shared helper: dynamic space list + Kanagawa color constants
# Source this from animation scripts: source "$PLUGIN_DIR/bar_colors.sh"

# Kanagawa Wave palette
K_WHITE=0xffDCD7BA      # fujiWhite — clock, slider highlight, battery
K_OLD_WHITE=0xffC8C093  # oldWhite — spaces, location, connection
K_DIM=0xff727169        # fujiGray — dim metrics, network stats, graphs
K_GRAPH_FILL=0x33727169 # 20% opacity fill

# Transparent versions (matching RGB, alpha=0x00)
T_WHITE=0x00DCD7BA
T_OLD_WHITE=0x00C8C093
T_DIM=0x00727169

# Dynamic space list — works for any number of spaces
get_spaces() {
  sketchybar --query bar 2>/dev/null | python3 -c "
import json,sys
[print(i) for i in json.load(sys.stdin)['items'] if i.startswith('space.') and i != 'space_handler']
" 2>/dev/null
}

# Build sketchybar args to set all spaces to a color
space_args_color() {
  local color="$1"
  local args=""
  for s in $(get_spaces); do
    args="$args --set $s icon.color=$color"
  done
  echo "$args"
}
