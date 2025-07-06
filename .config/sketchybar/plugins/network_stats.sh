#!/usr/bin/env sh

# Lightweight network stats - optimized version
SILVER=0xffB0B7C0

# Check connectivity once
CONNECTED=0
for iface in en0 en1; do
    if ifconfig $iface 2>/dev/null | grep -q 'status: active'; then
        CONNECTED=1
        break
    fi
done

if [ $CONNECTED -eq 0 ]; then
    sketchybar --set network_down label="" padding_right=0 \
               --set network_up label="" padding_right=0
    exit 0
fi

# Simple state file
STATE="/tmp/sketchybar_net_state"

# Get current network bytes - simplified
BYTES=$(netstat -ibn | awk '/^en[0-3].*<Link#/{rx+=$7; tx+=$10} END{print rx, tx}')
NOW=$(date +%s)

if [ -f "$STATE" ]; then
    read PREV_TIME PREV_RX PREV_TX < "$STATE"
    
    RX=$(echo "$BYTES" | awk '{print $1}')
    TX=$(echo "$BYTES" | awk '{print $2}')
    
    # Calculate KB/s
    TIME_DIFF=$((NOW - PREV_TIME))
    [ $TIME_DIFF -eq 0 ] && TIME_DIFF=1
    
    DOWN_KB=$(( (RX - PREV_RX) / TIME_DIFF / 1024 ))
    UP_KB=$(( (TX - PREV_TX) / TIME_DIFF / 1024 ))
    
    # Prevent negative values
    [ $DOWN_KB -lt 0 ] && DOWN_KB=0
    [ $UP_KB -lt 0 ] && UP_KB=0
    
    # Format output
    if [ $DOWN_KB -eq 0 ]; then
        DOWN_STR="↓0"
    elif [ $DOWN_KB -gt 999 ]; then
        DOWN_STR="↓$((DOWN_KB/1024))M"
    else
        DOWN_STR="↓${DOWN_KB}K"
    fi
    
    if [ $UP_KB -eq 0 ]; then
        UP_STR="↑0"
    elif [ $UP_KB -gt 999 ]; then
        UP_STR="↑$((UP_KB/1024))M"
    else
        UP_STR="↑${UP_KB}K"
    fi
    
    sketchybar --set network_down label="$DOWN_STR" label.color=$SILVER \
               --set network_up label="$UP_STR" label.color=$SILVER
else
    sketchybar --set network_down label="↓0" label.color=$SILVER \
               --set network_up label="↑0" label.color=$SILVER
fi

# Save state
echo "$NOW $RX $TX" > "$STATE"