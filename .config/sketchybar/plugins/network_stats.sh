#!/usr/bin/env sh

# Network stats with native graph component
# Single script triggered by network_down, updates all 4 items

WIFI_STATUS=$(ifconfig en0 2>/dev/null | grep 'status: active')
ETH_STATUS=$(ifconfig en1 2>/dev/null | grep 'status: active')

if [ -z "$WIFI_STATUS" ] && [ -z "$ETH_STATUS" ]; then
    sketchybar --set network_down icon.drawing=off label.drawing=off padding_right=0 \
               --set network_up icon.drawing=off label.drawing=off padding_right=0 \
               --set graph_down drawing=off \
               --set graph_up drawing=off
    exit 0
fi

# Check for default route
GW=$(route -n get default 2>/dev/null | grep 'gateway:' | awk '{print $2}')
if [ -z "$GW" ]; then
    sketchybar --set network_down icon.drawing=off label.drawing=off padding_right=0 \
               --set network_up icon.drawing=off label.drawing=off padding_right=0 \
               --set graph_down drawing=off \
               --set graph_up drawing=off
    exit 0
fi

PREV_FILE="/tmp/sketchybar_net_prev"

# Get current bytes across active interfaces (single netstat call, skip inactive)
CURRENT_DOWN=0
CURRENT_UP=0
NETSTAT_OUT=$(netstat -ibn)
for iface in en0 en1; do
    case "$iface" in
        en0) [ -z "$WIFI_STATUS" ] && continue ;;
        en1) [ -z "$ETH_STATUS" ] && continue ;;
    esac
    STATS=$(echo "$NETSTAT_OUT" | awk -v i="$iface" '$1==i{print; exit}')
    DOWN=$(echo "$STATS" | awk '{print $7}')
    UP=$(echo "$STATS" | awk '{print $10}')
    [ -n "$DOWN" ] && CURRENT_DOWN=$((CURRENT_DOWN + DOWN))
    [ -n "$UP" ] && CURRENT_UP=$((CURRENT_UP + UP))
done

if [ -f "$PREV_FILE" ]; then
    read PREV_DOWN PREV_UP < "$PREV_FILE"

    DIFF_DOWN=$((CURRENT_DOWN - PREV_DOWN))
    DIFF_UP=$((CURRENT_UP - PREV_UP))
    [ $DIFF_DOWN -lt 0 ] && DIFF_DOWN=0
    [ $DIFF_UP -lt 0 ] && DIFF_UP=0

    # KB/s (1 second interval)
    DOWN_KB=$((DIFF_DOWN / 1024))
    UP_KB=$((DIFF_UP / 1024))

    # Format label (max 2 digits + unit)
    if [ $DOWN_KB -lt 100 ]; then DOWN_STR="${DOWN_KB}K"
    else DOWN_STR="$(( (DOWN_KB + 1023) / 1024 ))M"; fi

    if [ $UP_KB -lt 100 ]; then UP_STR="${UP_KB}K"
    else UP_STR="$(( (UP_KB + 1023) / 1024 ))M"; fi

    # Normalize to 0.0-1.0 using log scale (awk):
    # 1K=0.0, 10K=0.33, 100K=0.67, 1000K=1.0
    GRAPH_DOWN=$(awk "BEGIN {v=0; if($DOWN_KB>0) v=log($DOWN_KB)/log(1000); if(v>1) v=1; if(v<0) v=0; printf \"%.3f\", v}")
    GRAPH_UP=$(awk "BEGIN {v=0; if($UP_KB>0) v=log($UP_KB)/log(1000); if(v>1) v=1; if(v<0) v=0; printf \"%.3f\", v}")

    # Colors: lavender→white→orange→red
    if [ $DOWN_KB -lt 50 ]; then DOWN_COLOR=0xff8A869E
    elif [ $DOWN_KB -lt 500 ]; then DOWN_COLOR=0xffFFFFFF
    elif [ $DOWN_KB -lt 5000 ]; then DOWN_COLOR=0xffFFA500
    else DOWN_COLOR=0xffE74C3C; fi

    if [ $UP_KB -lt 20 ]; then UP_COLOR=0xff8A869E
    elif [ $UP_KB -lt 200 ]; then UP_COLOR=0xffFFFFFF
    elif [ $UP_KB -lt 2000 ]; then UP_COLOR=0xffFFA500
    else UP_COLOR=0xffE74C3C; fi

    sketchybar --set network_down label="$DOWN_STR" label.color=$DOWN_COLOR icon.color=$DOWN_COLOR icon.drawing=on label.drawing=on \
               --set network_up label="$UP_STR" label.color=$UP_COLOR icon.color=$UP_COLOR icon.drawing=on label.drawing=on \
               --set graph_down graph.color=$DOWN_COLOR graph.fill_color=${DOWN_COLOR%??????}33${DOWN_COLOR#0x??} drawing=on \
               --set graph_up graph.color=$UP_COLOR graph.fill_color=${UP_COLOR%??????}33${UP_COLOR#0x??} drawing=on \
               --push graph_down $GRAPH_DOWN \
               --push graph_up $GRAPH_UP
else
    sketchybar --set network_down label="0K" label.color=0xff8A869E icon.color=0xff8A869E icon.drawing=on label.drawing=on \
               --set network_up label="0K" label.color=0xff8A869E icon.color=0xff8A869E icon.drawing=on label.drawing=on \
               --set graph_down drawing=on \
               --set graph_up drawing=on \
               --push graph_down 0.0 \
               --push graph_up 0.0
fi

echo "$CURRENT_DOWN $CURRENT_UP" > "$PREV_FILE"
