#!/bin/bash
# Startup cascade: set transparent → fade in from edges → launch daemon
# No --update — avoids space.sh flash. Spaces use default gray; space.sh corrects on first event.

D=40  W=0.35
PLUGIN_DIR="$HOME/.config/sketchybar/plugins"

# Disable space.sh during cascade (typing triggers space_windows_change which overwrites colors)
sketchybar --set space_handler script=""

# Set everything transparent immediately
sketchybar \
  --set logo background.image.scale=0 \
  --set space.1 icon.color=0x00A0A0A0 --set space.2 icon.color=0x00A0A0A0 \
  --set space.3 icon.color=0x00A0A0A0 --set space.4 icon.color=0x00A0A0A0 \
  --set space.5 icon.color=0x00A0A0A0 --set space.6 icon.color=0x00A0A0A0 \
  --set space.7 icon.color=0x00A0A0A0 \
  --set location icon.color=0x00B0B7C0 label.color=0x00B0B7C0 \
  --set connection icon.color=0x00B0B7C0 label.color=0x00B0B7C0 \
  --set network_down icon.color=0x008A869E label.color=0x008A869E \
  --set graph_down graph.color=0x008A869E graph.fill_color=0x008A869E \
  --set network_up icon.color=0x008A869E label.color=0x008A869E \
  --set graph_up graph.color=0x008A869E graph.fill_color=0x008A869E \
  --set progress_icon icon.color=0x00FFFFFF \
  --set progress icon.color=0x00A0A0A0 label.color=0x00A0A0A0 \
      slider.highlight_color=0x00FFFFFF slider.background.color=0x008A869E \
  --set clock_time label.color=0x00FFFFFF \
  --set battery icon.color=0x00FFFFFF label.color=0x00FFFFFF \
  --set disk icon.color=0x008A869E label.color=0x008A869E \
  --set memory icon.color=0x008A869E label.color=0x008A869E \
  --set cpu icon.color=0x008A869E label.color=0x008A869E \
  --set gpu icon.color=0x008A869E label.color=0x008A869E \
  --set power icon.color=0x008A869E label.color=0x008A869E \
  --set temp icon.color=0x008A869E label.color=0x008A869E

# Cascade immediately — all spaces fade in as gray, space.sh corrects colors later
G=0xffA0A0A0

sketchybar --animate sin $D --set logo background.image.scale=0.048 --set clock_time label.color=0xffFFFFFF
sleep $W
sketchybar --animate sin $D --set space.1 icon.color=$G --set progress_icon icon.color=0xffFFFFFF --set progress icon.color=0xffA0A0A0 label.color=0xffA0A0A0 slider.highlight_color=0xffFFFFFF slider.background.color=0xff8A869E
sleep $W
sketchybar --animate sin $D --set space.2 icon.color=$G --set battery icon.color=0xffFFFFFF label.color=0xffFFFFFF
sleep $W
sketchybar --animate sin $D --set space.3 icon.color=$G --set disk icon.color=0xff8A869E label.color=0xff8A869E
sleep $W
sketchybar --animate sin $D --set space.4 icon.color=$G --set memory icon.color=0xff8A869E label.color=0xff8A869E
sleep $W
sketchybar --animate sin $D --set space.5 icon.color=$G --set cpu icon.color=0xff8A869E label.color=0xff8A869E
sleep $W
sketchybar --animate sin $D --set space.6 icon.color=$G --set gpu icon.color=0xff8A869E label.color=0xff8A869E
sleep $W
sketchybar --animate sin $D --set space.7 icon.color=$G --set power icon.color=0xff8A869E label.color=0xff8A869E
sleep $W
sketchybar --animate sin $D --set location icon.color=0xffB0B7C0 label.color=0xffB0B7C0 --set temp icon.color=0xff8A869E label.color=0xff8A869E
sleep $W
sketchybar --animate sin $D --set connection icon.color=0xffB0B7C0 label.color=0xffB0B7C0
sleep 0.2
sketchybar --animate sin $D --set network_down icon.color=0xff8A869E label.color=0xff8A869E --set graph_down graph.color=0xff8A869E graph.fill_color=0x338A869E
sleep 0.2
sketchybar --animate sin $D --set network_up icon.color=0xff8A869E label.color=0xff8A869E --set graph_up graph.color=0xff8A869E graph.fill_color=0x338A869E

# Re-enable space.sh and trigger --update so it sets correct active/occupied colors
sketchybar --set space_handler script="$PLUGIN_DIR/space.sh"
sketchybar --update

# Launch bar-daemon
"$HOME/.config/sketchybar/helpers/bar-daemon" &
