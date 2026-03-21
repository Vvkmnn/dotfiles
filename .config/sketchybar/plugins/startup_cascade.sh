#!/bin/bash
# Startup cascade: set transparent + collapsed → fade+expand from edges → launch daemon
# Kanagawa Wave palette via bar_colors.sh

D=40  W=0.35
PLUGIN_DIR="$HOME/.config/sketchybar/plugins"
source "$PLUGIN_DIR/bar_colors.sh"

# Disable space.sh during cascade
sketchybar --set space_handler script=""

# Get all space items dynamically
SPACES=($(get_spaces))

# Set everything transparent (items already width=0 from sketchybarrc)
SPACE_TRANSPARENT=""
for s in "${SPACES[@]}"; do
  SPACE_TRANSPARENT="$SPACE_TRANSPARENT --set $s icon.color=$T_OLD_WHITE"
done

sketchybar \
  --set logo background.image.scale=0 \
  $SPACE_TRANSPARENT \
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

# Outside-in cascade: fade color + expand width simultaneously
# Left side: spaces paired with right side items
# Right items in order: clock, progress, battery, disk, memory, cpu, gpu, power, temp
RIGHT_ITEMS=(clock_time progress battery disk memory cpu gpu power temp)
NUM_SPACES=${#SPACES[@]}
NUM_RIGHT=${#RIGHT_ITEMS[@]}
WAVES=$(( NUM_SPACES > NUM_RIGHT ? NUM_SPACES : NUM_RIGHT ))

# W1: logo + clock_time (always first)
sketchybar --animate tanh $D --set clock_time width=dynamic --animate sin $D --set logo background.image.scale=0.048 --set clock_time label.color=$K_WHITE
sleep $W

# W2: first space + progress section
sketchybar --animate tanh $D --set progress_icon width=dynamic --set progress width=dynamic \
  --animate sin $D --set "${SPACES[0]}" icon.color=$K_OLD_WHITE \
  --set progress_icon icon.color=$K_WHITE --set progress icon.color=$K_OLD_WHITE label.color=$K_OLD_WHITE slider.highlight_color=$K_WHITE slider.background.color=$K_DIM
sleep $W

# W3: space + battery
sketchybar --animate tanh $D --set battery width=dynamic --animate sin $D --set "${SPACES[1]}" icon.color=$K_OLD_WHITE --set battery icon.color=$K_WHITE label.color=$K_WHITE
sleep $W

# W4+: remaining spaces paired with right-side items
RIGHT_DIM_ITEMS=(disk memory cpu gpu power temp)
for i in $(seq 2 $((NUM_SPACES - 1))); do
  ri=$((i - 2))  # index into RIGHT_DIM_ITEMS
  RIGHT_CMD=""
  if [ $ri -lt ${#RIGHT_DIM_ITEMS[@]} ]; then
    RIGHT_CMD="--animate tanh $D --set ${RIGHT_DIM_ITEMS[$ri]} width=dynamic --animate sin $D --set ${RIGHT_DIM_ITEMS[$ri]} icon.color=$K_DIM label.color=$K_DIM"
  fi
  sketchybar --animate sin $D --set "${SPACES[$i]}" icon.color=$K_OLD_WHITE $RIGHT_CMD
  sleep $W
done

# Fade in any remaining right-side items not paired with spaces
PAIRED=$((NUM_SPACES - 2))
for ri in $(seq $PAIRED $((${#RIGHT_DIM_ITEMS[@]} - 1))); do
  sketchybar --animate tanh $D --set ${RIGHT_DIM_ITEMS[$ri]} width=dynamic --animate sin $D --set ${RIGHT_DIM_ITEMS[$ri]} icon.color=$K_DIM label.color=$K_DIM
  sleep $W
done

# Location + temp meet at notch (temp may already be done above, but re-setting is harmless)
sketchybar --animate sin $D --set location icon.color=$K_OLD_WHITE label.color=$K_OLD_WHITE
sleep $W

# Network section
sketchybar --animate sin $D --set connection icon.color=$K_OLD_WHITE label.color=$K_OLD_WHITE
sleep 0.2
sketchybar --animate sin $D --set network_down icon.color=$K_DIM label.color=$K_DIM --set graph_down graph.color=$K_DIM graph.fill_color=$K_GRAPH_FILL
sleep 0.2
sketchybar --animate sin $D --set network_up icon.color=$K_DIM label.color=$K_DIM --set graph_up graph.color=$K_DIM graph.fill_color=$K_GRAPH_FILL

# Launch bar-daemon BEFORE --update (--update blocks on space.sh yabai query)
"$HOME/.config/sketchybar/helpers/bar-daemon" &

# Re-enable space.sh and trigger --update (background so it doesn't block)
sketchybar --set space_handler script="$PLUGIN_DIR/space.sh"
sketchybar --update &
