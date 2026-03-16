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
    sketchybar --set network_down label="↓ 0K" label.color=$SILVER \
               --set network_up label="↑ 0K" label.color=$SILVER
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
    
    format_rate() {
        local kb="$1"
        local val
        if [ "$kb" -ge 1024 ]; then
            val=$((kb / 1024))
            [ "$val" -gt 99 ] && val=99
            printf "%2dM" "$val"
        else
            [ "$kb" -gt 99 ] && kb=99
            printf "%2dK" "$kb"
        fi
    }

    DOWN_STR="↓$(format_rate "$DOWN_KB")"
    UP_STR="↑$(format_rate "$UP_KB")"
    
    sketchybar --set network_down label="$DOWN_STR" label.color=$SILVER \
               --set network_up label="$UP_STR" label.color=$SILVER
else
    sketchybar --set network_down label="↓ 0K" label.color=$SILVER \
               --set network_up label="↑ 0K" label.color=$SILVER
fi

# Save state
echo "$NOW $RX $TX" > "$STATE"
