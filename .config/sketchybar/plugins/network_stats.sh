#!/usr/bin/env sh

# Network stats - truly independent download/upload indicators
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
    
    # Update history - keep only 4 samples
    if [ -f "$HIST_FILE" ]; then
        HISTORY=$(tail -3 "$HIST_FILE" 2>/dev/null)
        echo "$HISTORY" > "$HIST_FILE"
        echo "$DOWN_KB $UP_KB" >> "$HIST_FILE"
    else
        echo "$DOWN_KB $UP_KB" > "$HIST_FILE"
    fi
    
    # Sparkline characters - using shaded squares with proper gradation
    # Using shade blocks that look square-ish and show clear progression
    SPARKLINE_CHARS=("·" "░" "░" "▒" "▒" "▓" "▓" "█")
    
    # Create sparklines
    DOWN_SPARK=""
    UP_SPARK=""
    
    # Ensure we always have 4 samples for display
    SAMPLES=0
    while read -r line; do
        D=$(echo $line | cut -d' ' -f1)
        U=$(echo $line | cut -d' ' -f2)
        
        # Download sparkline height - more sensitive to low values
        if [ $D -eq 0 ]; then
            D_IDX=0
        elif [ $D -lt 10 ]; then
            D_IDX=1
        elif [ $D -lt 50 ]; then
            D_IDX=2
        elif [ $D -lt 100 ]; then
            D_IDX=3
        elif [ $D -lt 500 ]; then
            D_IDX=4
        elif [ $D -lt 1000 ]; then
            D_IDX=5
        elif [ $D -lt 5000 ]; then
            D_IDX=6
        else
            D_IDX=7
        fi
        
        # Upload sparkline height - more sensitive to low values
        if [ $U -eq 0 ]; then
            U_IDX=0
        elif [ $U -lt 10 ]; then
            U_IDX=1
        elif [ $U -lt 50 ]; then
            U_IDX=2
        elif [ $U -lt 100 ]; then
            U_IDX=3
        elif [ $U -lt 500 ]; then
            U_IDX=4
        elif [ $U -lt 1000 ]; then
            U_IDX=5
        elif [ $U -lt 5000 ]; then
            U_IDX=6
        else
            U_IDX=7
        fi
        
        DOWN_SPARK="${DOWN_SPARK}${SPARKLINE_CHARS[$D_IDX]}"
        UP_SPARK="${UP_SPARK}${SPARKLINE_CHARS[$U_IDX]}"
        SAMPLES=$((SAMPLES + 1))
    done < "$HIST_FILE"
    
    # Fill remaining slots with minimal indicator if less than 4 samples
    while [ $SAMPLES -lt 4 ]; do
        DOWN_SPARK="${DOWN_SPARK}▁"
        UP_SPARK="${UP_SPARK}▁"
        SAMPLES=$((SAMPLES + 1))
    done
    
    # Format speeds
    if [ $DOWN_KB -eq 0 ]; then
        DOWN_STR=" 0"
    elif [ $DOWN_KB -gt 9999 ]; then
        DOWN_STR="$(printf "%2dM" $((DOWN_KB/1024)))"
    elif [ $DOWN_KB -gt 999 ]; then
        DOWN_STR="$(printf "%1.0fM" $(echo "scale=0; $DOWN_KB/1024" | bc))"
    else
        DOWN_STR="$(printf "%2dK" $DOWN_KB)"
    fi
    
    if [ $UP_KB -eq 0 ]; then
        UP_STR=" 0"
    elif [ $UP_KB -gt 9999 ]; then
        UP_STR="$(printf "%2dM" $((UP_KB/1024)))"
    elif [ $UP_KB -gt 999 ]; then
        UP_STR="$(printf "%1.0fM" $(echo "scale=0; $UP_KB/1024" | bc))"
    else
        UP_STR="$(printf "%2dK" $UP_KB)"
    fi
    
    # Independent colors - using off-white shades for all activity levels
    if [ $DOWN_KB -eq 0 ]; then
        DOWN_COLOR=0xffF8F0E0  # Kanagawa off-white
    elif [ $DOWN_KB -lt 100 ]; then
        DOWN_COLOR=0xffF8F0E0  # Kanagawa off-white
    elif [ $DOWN_KB -lt 1000 ]; then
        DOWN_COLOR=0xffDDB670  # Yellow for moderate
    else
        DOWN_COLOR=0xffE74C3C  # Red for high
    fi
    
    if [ $UP_KB -eq 0 ]; then
        UP_COLOR=0xffF8F0E0  # Kanagawa off-white
    elif [ $UP_KB -lt 100 ]; then
        UP_COLOR=0xffF8F0E0  # Kanagawa off-white
    elif [ $UP_KB -lt 1000 ]; then
        UP_COLOR=0xffDDB670  # Yellow
    else
        UP_COLOR=0xffE74C3C  # Red
    fi
    
    # Update items - arrows always off-white, numbers change color based on activity
    # Ensure consistent font sizing with SF Pro Regular 13
    sketchybar --set network_down label="↓${DOWN_STR} ${DOWN_SPARK}" \
                                 label.color=$DOWN_COLOR \
                                 label.font="SF Pro:Regular:13.0" \
                                 label.drawing=on \
                                 padding_right=2 \
               --set network_up label="↑${UP_STR} ${UP_SPARK}" \
                               label.color=$UP_COLOR \
                               label.font="SF Pro:Regular:13.0" \
                               label.drawing=on \
                               padding_right=8
else
    # No previous data - show minimal sparklines, off-white
    sketchybar --set network_down label="↓ 0 ····" label.color=0xffF8F0E0 label.font="SF Pro:Regular:13.0" label.drawing=on padding_right=2 \
               --set network_up label="↑ 0 ····" label.color=0xffF8F0E0 label.font="SF Pro:Regular:13.0" label.drawing=on padding_right=8
fi

echo "$CURRENT_DOWN $CURRENT_UP" > "$PREV_FILE"