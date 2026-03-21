#!/bin/bash
# Internet disconnect/reconnect animations
# SIGUSR2 = persistent lock on network items, SIGUSR1 = unlock + smooth + location refresh
# Kanagawa palette: kDim=727169, kOldWhite=C8C093, kWhite=DCD7BA

D=25  W=0.3

case "$SENDER" in
internet_disconnect)
    # Persistent lock — bar-daemon won't write to network items until SIGUSR1
    kill -USR2 $(pgrep -f "helpers/bar-daemon") 2>/dev/null
    sleep 0.2

    # Inside-out collapse with Kanagawa colors
    sketchybar --animate sin $D --set graph_up graph.color=0x00727169 graph.fill_color=0x00727169
    sleep $W
    sketchybar --set graph_up drawing=off

    sketchybar --animate sin $D --set network_up icon.color=0x00727169 label.color=0x00727169
    sleep $W
    sketchybar --set network_up icon.drawing=off label.drawing=off

    sketchybar --animate sin $D --set graph_down graph.color=0x00727169 graph.fill_color=0x00727169
    sleep $W
    sketchybar --set graph_down drawing=off

    sketchybar --animate sin $D --set network_down icon.color=0x00727169 label.color=0x00727169
    sleep $W
    sketchybar --set network_down icon.drawing=off label.drawing=off

    sketchybar --animate sin $D --set connection icon.color=0x00C8C093 label.color=0x00C8C093
    sleep $W
    sketchybar --set connection icon.drawing=off label.drawing=off

    sketchybar --animate sin $D --set location icon.color=0x00C8C093 label.color=0x00C8C093
    sleep $W
    sketchybar --set location "icon=󰇨" label= label.drawing=off
    sketchybar --animate sin 30 --set location icon.color=0xff727169
    ;;

internet_reconnect)
    # Persistent lock during animation
    kill -USR2 $(pgrep -f "helpers/bar-daemon") 2>/dev/null
    sleep 0.2

    # Fade globe out
    sketchybar --animate sin $D --set location icon.color=0x00727169
    sleep 0.4

    # Outside-in expand with Kanagawa colors
    sketchybar --set location "icon=󰖟" icon.color=0x00C8C093 label.drawing=on label.color=0x00C8C093
    sketchybar --animate sin $D --set location icon.color=0xffC8C093 label.color=0xffC8C093
    sleep $W

    sketchybar --set connection icon.drawing=on label.drawing=on icon.color=0x00C8C093 label.color=0x00C8C093
    sketchybar --animate sin $D --set connection icon.color=0xffC8C093 label.color=0xffC8C093
    sleep $W

    sketchybar --set network_down icon.drawing=on label.drawing=on icon.color=0x00727169 label.color=0x00727169
    sketchybar --animate sin $D --set network_down icon.color=0xff727169 label.color=0xff727169
    sleep $W

    sketchybar --set graph_down drawing=on graph.color=0x00727169 graph.fill_color=0x00727169
    sketchybar --animate sin $D --set graph_down graph.color=0xff727169 graph.fill_color=0x33727169
    sleep $W

    sketchybar --set network_up icon.drawing=on label.drawing=on icon.color=0x00727169 label.color=0x00727169
    sketchybar --animate sin $D --set network_up icon.color=0xff727169 label.color=0xff727169
    sleep $W

    sketchybar --set graph_up drawing=on graph.color=0x00727169 graph.fill_color=0x00727169
    sketchybar --animate sin $D --set graph_up graph.color=0xff727169 graph.fill_color=0x33727169

    # Unlock + smooth mode + location refresh
    kill -USR1 $(pgrep -f "helpers/bar-daemon") 2>/dev/null
    ;;
esac
