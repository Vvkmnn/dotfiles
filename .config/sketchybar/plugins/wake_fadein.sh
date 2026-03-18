#!/bin/bash
# Wake/unlock fade-in: SIGUSR1 bar-daemon → transparent → smooth fade in
# Triggered by system_woke (covers lid open, display wake, AND password unlock)

# Tell bar-daemon to animate its updates for the next 3s
kill -USR1 $(pgrep -f "helpers/bar-daemon") 2>/dev/null

# Set everything transparent, hide graphs
sketchybar \
  --set logo background.image.scale=0 \
  --set space.1 icon.color=0x00A0A0A0 --set space.2 icon.color=0x00A0A0A0 \
  --set space.3 icon.color=0x00A0A0A0 --set space.4 icon.color=0x00A0A0A0 \
  --set space.5 icon.color=0x00A0A0A0 --set space.6 icon.color=0x00A0A0A0 \
  --set space.7 icon.color=0x00A0A0A0 \
  --set location icon.color=0x00B0B7C0 label.color=0x00B0B7C0 \
  --set connection icon.color=0x00B0B7C0 label.color=0x00B0B7C0 \
  --set network_down icon.color=0x008A869E label.color=0x008A869E \
  --set graph_down drawing=off \
  --set network_up icon.color=0x008A869E label.color=0x008A869E \
  --set graph_up drawing=off \
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

sleep 0.8

# Restore graphs then fade everything in (~1.5s)
sketchybar --set graph_down drawing=on --set graph_up drawing=on
sketchybar --animate sin 90 \
  --set logo background.image.scale=0.048 \
  --set space.1 icon.color=0xffA0A0A0 --set space.2 icon.color=0xffA0A0A0 \
  --set space.3 icon.color=0xffA0A0A0 --set space.4 icon.color=0xffA0A0A0 \
  --set space.5 icon.color=0xffA0A0A0 --set space.6 icon.color=0xffA0A0A0 \
  --set space.7 icon.color=0xffA0A0A0 \
  --set location icon.color=0xffB0B7C0 label.color=0xffB0B7C0 \
  --set connection icon.color=0xffB0B7C0 label.color=0xffB0B7C0 \
  --set network_down icon.color=0xff8A869E label.color=0xff8A869E \
  --set graph_down graph.color=0xff8A869E graph.fill_color=0x338A869E \
  --set network_up icon.color=0xff8A869E label.color=0xff8A869E \
  --set graph_up graph.color=0xff8A869E graph.fill_color=0x338A869E \
  --set progress_icon icon.color=0xffFFFFFF \
  --set progress icon.color=0xffA0A0A0 label.color=0xffA0A0A0 \
      slider.highlight_color=0xffFFFFFF slider.background.color=0xff8A869E \
  --set clock_time label.color=0xffFFFFFF \
  --set battery icon.color=0xffFFFFFF label.color=0xffFFFFFF \
  --set disk icon.color=0xff8A869E label.color=0xff8A869E \
  --set memory icon.color=0xff8A869E label.color=0xff8A869E \
  --set cpu icon.color=0xff8A869E label.color=0xff8A869E \
  --set gpu icon.color=0xff8A869E label.color=0xff8A869E \
  --set power icon.color=0xff8A869E label.color=0xff8A869E \
  --set temp icon.color=0xff8A869E label.color=0xff8A869E
