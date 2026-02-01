#!/usr/bin/env sh

# Network stats - truly independent download/upload indicators
LAVENDER=0xff8A869E

WIFI_STATUS=$(ifconfig en0 2>/dev/null | grep 'status: active')
ETH_STATUS=$(ifconfig en1 2>/dev/null | grep 'status: active')

if [ -z "$WIFI_STATUS" ] && [ -z "$ETH_STATUS" ]; then
    sketchybar --set network_down label="" label.drawing=off padding_right=0 \
               --set network_up label="" label.drawing=off padding_right=0
    exit 0
fi

# Files for tracking
HIST_FILE="/tmp/sketchybar_net_history"
PREV_FILE="/tmp/sketchybar_net_prev"

# Get current bytes
CURRENT_DOWN=0
CURRENT_UP=0

for iface in en0 en1 en2 en3; do
    if ifconfig $iface 2>/dev/null | grep -q 'status: active'; then
        DOWN=$(netstat -ibn | grep "^$iface" | head -1 | awk '{print $7}')
        UP=$(netstat -ibn | grep "^$iface" | head -1 | awk '{print $10}')
        [ -n "$DOWN" ] && CURRENT_DOWN=$((CURRENT_DOWN + DOWN))
        [ -n "$UP" ] && CURRENT_UP=$((CURRENT_UP + UP))
    fi
done

# Debug the actual values
echo "RAW: iface stats DOWN=$CURRENT_DOWN UP=$CURRENT_UP" >> /tmp/network_debug.log

# Calculate speeds
if [ -f "$PREV_FILE" ]; then
    PREV_DOWN=$(cat "$PREV_FILE" | cut -d' ' -f1)
    PREV_UP=$(cat "$PREV_FILE" | cut -d' ' -f2)
    
    DIFF_DOWN=$((CURRENT_DOWN - PREV_DOWN))
    DIFF_UP=$((CURRENT_UP - PREV_UP))
    
    [ $DIFF_DOWN -lt 0 ] && DIFF_DOWN=0
    [ $DIFF_UP -lt 0 ] && DIFF_UP=0
    
    # Add small variation to prevent identical sparklines when activity is low
    if [ $DIFF_DOWN -lt 10240 ] && [ $DIFF_UP -lt 10240 ]; then
        # For low activity, add slight variation based on time
        RAND=$(( $(date +%S) % 10 ))
        if [ $((RAND % 2)) -eq 0 ]; then
            DIFF_DOWN=$((DIFF_DOWN + RAND * 256))
        else
            DIFF_UP=$((DIFF_UP + RAND * 256))
        fi
    fi
    
    # Convert to KB/s (2 second interval)
    DOWN_KB=$((DIFF_DOWN / 2048))
    UP_KB=$((DIFF_UP / 2048))
    
    # Update history - keep only 3 samples for cleaner display
    if [ -f "$HIST_FILE" ]; then
        HISTORY=$(tail -2 "$HIST_FILE" 2>/dev/null)
        echo "$HISTORY" > "$HIST_FILE"
        echo "$DOWN_KB $UP_KB" >> "$HIST_FILE"
    else
        echo "$DOWN_KB $UP_KB" > "$HIST_FILE"
    fi

    # Sparkline: 8 height levels
    SPARK=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")

    DOWN_SPARK=""
    UP_SPARK=""
    SAMPLES=0

    while read -r line; do
        D=$(echo $line | cut -d' ' -f1)
        U=$(echo $line | cut -d' ' -f2)

        # Download: 8 levels (KB/s)
        if [ $D -lt 10 ]; then D_IDX=0
        elif [ $D -lt 50 ]; then D_IDX=1
        elif [ $D -lt 150 ]; then D_IDX=2
        elif [ $D -lt 400 ]; then D_IDX=3
        elif [ $D -lt 800 ]; then D_IDX=4
        elif [ $D -lt 2000 ]; then D_IDX=5
        elif [ $D -lt 5000 ]; then D_IDX=6
        else D_IDX=7; fi

        # Upload: 8 levels (more sensitive)
        if [ $U -lt 5 ]; then U_IDX=0
        elif [ $U -lt 25 ]; then U_IDX=1
        elif [ $U -lt 75 ]; then U_IDX=2
        elif [ $U -lt 200 ]; then U_IDX=3
        elif [ $U -lt 500 ]; then U_IDX=4
        elif [ $U -lt 1000 ]; then U_IDX=5
        elif [ $U -lt 3000 ]; then U_IDX=6
        else U_IDX=7; fi

        DOWN_SPARK="${DOWN_SPARK}${SPARK[$D_IDX]}"
        UP_SPARK="${UP_SPARK}${SPARK[$U_IDX]}"
        SAMPLES=$((SAMPLES + 1))
    done < "$HIST_FILE"

    # Fill to 3 samples
    while [ $SAMPLES -lt 3 ]; do
        DOWN_SPARK="${DOWN_SPARK}▁"
        UP_SPARK="${UP_SPARK}▁"
        SAMPLES=$((SAMPLES + 1))
    done
    
    # Format: integers only (K=KB/s, M=MB/s)
    format_speed() {
        local kb=$1
        if [ $kb -lt 1000 ]; then printf "%dK" $kb
        else printf "%dM" $((kb/1024)); fi
    }

    DOWN_STR=$(format_speed $DOWN_KB)
    UP_STR=$(format_speed $UP_KB)
    
    # Colors: lavender→white→orange→red (down/up have different thresholds)
    # Down: <100K lavender, 100K-5M white, 5M-20M orange, >20M red
    if [ $DOWN_KB -lt 100 ]; then DOWN_COLOR=0xff8A869E
    elif [ $DOWN_KB -lt 5000 ]; then DOWN_COLOR=0xffFFFFFF
    elif [ $DOWN_KB -lt 20000 ]; then DOWN_COLOR=0xffFFA500
    else DOWN_COLOR=0xffE74C3C; fi

    # Up: <50K lavender, 50K-2M white, 2M-10M orange, >10M red
    if [ $UP_KB -lt 50 ]; then UP_COLOR=0xff8A869E
    elif [ $UP_KB -lt 2000 ]; then UP_COLOR=0xffFFFFFF
    elif [ $UP_KB -lt 10000 ]; then UP_COLOR=0xffFFA500
    else UP_COLOR=0xffE74C3C; fi

    sketchybar --set network_down label="↓${DOWN_STR} ${DOWN_SPARK}" \
                                 label.color=$DOWN_COLOR \
                                 label.font="SF Pro:Regular:13.0" \
                                 label.drawing=on \
               --set network_up label="↑${UP_STR} ${UP_SPARK}" \
                               label.color=$UP_COLOR \
                               label.font="SF Pro:Regular:13.0" \
                               label.drawing=on
else
    # No previous data (lavender = idle)
    sketchybar --set network_down label="↓0K ▁▁▁" label.color=0xff8A869E label.font="SF Pro:Regular:13.0" label.drawing=on \
               --set network_up label="↑0K ▁▁▁" label.color=0xff8A869E label.font="SF Pro:Regular:13.0" label.drawing=on
fi

echo "$CURRENT_DOWN $CURRENT_UP" > "$PREV_FILE"