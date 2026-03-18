#!/bin/bash
# Internet disconnect/reconnect animations
# Triggered by bar-daemon via: sketchybar --trigger internet_disconnect/internet_reconnect

D=25  # frames (~0.42s)
W=0.3 # seconds between steps

case "$SENDER" in
internet_disconnect)
    # Inside-out collapse: innermost items first, ending with globe
    sketchybar --animate sin $D --set graph_up graph.color=0x008A869E graph.fill_color=0x008A869E
    sleep $W
    sketchybar --set graph_up drawing=off

    sketchybar --animate sin $D --set network_up icon.color=0x008A869E label.color=0x008A869E
    sleep $W
    sketchybar --set network_up icon.drawing=off label.drawing=off

    sketchybar --animate sin $D --set graph_down graph.color=0x008A869E graph.fill_color=0x008A869E
    sleep $W
    sketchybar --set graph_down drawing=off

    sketchybar --animate sin $D --set network_down icon.color=0x008A869E label.color=0x008A869E
    sleep $W
    sketchybar --set network_down icon.drawing=off label.drawing=off

    sketchybar --animate sin $D --set connection icon.color=0x00B0B7C0 label.color=0x00B0B7C0
    sleep $W
    sketchybar --set connection icon.drawing=off label.drawing=off

    sketchybar --animate sin $D --set location icon.color=0x00B0B7C0 label.color=0x00B0B7C0
    sleep $W
    sketchybar --set location "icon=󰇨" label= label.drawing=off
    sketchybar --animate sin 30 --set location icon.color=0xff8A869E
    ;;

internet_reconnect)
    # Fade globe out, then outside-in expand with fade
    sketchybar --animate sin $D --set location icon.color=0x008A869E
    sleep 0.4

    sketchybar --set location icon.color=0x00B0B7C0 label.drawing=on label.color=0x00B0B7C0
    sketchybar --animate sin $D --set location icon.color=0xffB0B7C0 label.color=0xffB0B7C0
    sleep $W

    sketchybar --set connection icon.drawing=on label.drawing=on icon.color=0x00B0B7C0 label.color=0x00B0B7C0
    sketchybar --animate sin $D --set connection icon.color=0xffB0B7C0 label.color=0xffB0B7C0
    sleep $W

    sketchybar --set network_down icon.drawing=on label.drawing=on icon.color=0x008A869E label.color=0x008A869E
    sketchybar --animate sin $D --set network_down icon.color=0xff8A869E label.color=0xff8A869E
    sleep $W

    sketchybar --set graph_down drawing=on graph.color=0x008A869E graph.fill_color=0x008A869E
    sketchybar --animate sin $D --set graph_down graph.color=0xff8A869E graph.fill_color=0x338A869E
    sleep $W

    sketchybar --set network_up icon.drawing=on label.drawing=on icon.color=0x008A869E label.color=0x008A869E
    sketchybar --animate sin $D --set network_up icon.color=0xff8A869E label.color=0xff8A869E
    sleep $W

    sketchybar --set graph_up drawing=on graph.color=0x008A869E graph.fill_color=0x008A869E
    sketchybar --animate sin $D --set graph_up graph.color=0xff8A869E graph.fill_color=0x338A869E
    ;;
esac
