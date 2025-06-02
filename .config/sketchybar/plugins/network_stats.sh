#!/usr/bin/env sh

# Network stats - accurate speed calculations with proper color scheme
WIFI_STATUS=$(ifconfig en0 2>/dev/null | grep 'status: active')
ETH_STATUS=$(ifconfig en1 2>/dev/null | grep 'status: active')

if [ -z "$WIFI_STATUS" ] && [ -z "$ETH_STATUS" ]; then
    # No connection - hide completely
    sketchybar --set network_stats label="" \
                                  label.drawing=off \
                                  padding_left=0 \
                                  padding_right=0
    exit 0
fi

# Connected - show stats
# Get current bytes for all interfaces
CURRENT_DOWN=0
CURRENT_UP=0

# Sum up all active interfaces
for iface in en0 en1 en2 en3; do
    if ifconfig $iface 2>/dev/null | grep -q 'status: active'; then
        DOWN=$(netstat -ibn | grep "^$iface" | head -1 | awk '{print $7}')
        UP=$(netstat -ibn | grep "^$iface" | head -1 | awk '{print $10}')
        [ -n "$DOWN" ] && CURRENT_DOWN=$((CURRENT_DOWN + DOWN))
        [ -n "$UP" ] && CURRENT_UP=$((CURRENT_UP + UP))
    fi
done

PREV_FILE="/tmp/sketchybar_net_prev"
if [ -f "$PREV_FILE" ]; then
    PREV_DOWN=$(cat "$PREV_FILE" | cut -d' ' -f1)
    PREV_UP=$(cat "$PREV_FILE" | cut -d' ' -f2)
    
    # Calculate difference
    DIFF_DOWN=$((CURRENT_DOWN - PREV_DOWN))
    DIFF_UP=$((CURRENT_UP - PREV_UP))
    
    # Prevent negative values (happens on counter reset)
    [ $DIFF_DOWN -lt 0 ] && DIFF_DOWN=0
    [ $DIFF_UP -lt 0 ] && DIFF_UP=0
    
    # Convert to KB/s (2 second interval)
    DOWN_KB=$((DIFF_DOWN / 2048))
    UP_KB=$((DIFF_UP / 2048))
    
    # Format for display
    if [ $DOWN_KB -gt 999 ]; then
        DOWN_STR="$(($DOWN_KB / 1024))M"
    else
        DOWN_STR="${DOWN_KB}K"
    fi
    
    if [ $UP_KB -gt 999 ]; then
        UP_STR="$(($UP_KB / 1024))M"
    else
        UP_STR="${UP_KB}K"
    fi
    
    # Independent color for down and up speeds
    # Download color
    if [ $DOWN_KB -lt 10 ]; then
        DOWN_COLOR=0xff606060  # Dim gray (idle/minimal)
    elif [ $DOWN_KB -lt 1000 ]; then
        DOWN_COLOR=0xffFFFFFF  # White (active)
    elif [ $DOWN_KB -lt 10000 ]; then
        DOWN_COLOR=0xffDDB670  # Yellow (high activity)
    else
        DOWN_COLOR=0xffE74C3C  # Red (very high)
    fi
    
    # Upload color
    if [ $UP_KB -lt 10 ]; then
        UP_COLOR=0xff606060  # Dim gray (idle/minimal)
    elif [ $UP_KB -lt 1000 ]; then
        UP_COLOR=0xffFFFFFF  # White (active)
    elif [ $UP_KB -lt 10000 ]; then
        UP_COLOR=0xffDDB670  # Yellow (high activity)
    else
        UP_COLOR=0xffE74C3C  # Red (very high)
    fi
    
    # Use the more active color for the overall display
    if [ $DOWN_KB -gt $UP_KB ]; then
        COLOR=$DOWN_COLOR
    else
        COLOR=$UP_COLOR
    fi
else
    DOWN_STR="0K"
    UP_STR="0K"
    COLOR=0xff606060
fi

# Save current values
echo "$CURRENT_DOWN $CURRENT_UP" > "$PREV_FILE"

# Update display with fixed width
sketchybar --set network_stats label="$(printf "↓%4s ↑%4s" "$DOWN_STR" "$UP_STR")" \
                              label.color=$COLOR \
                              label.drawing=on \
                              padding_left=0 \
                              padding_right=10
