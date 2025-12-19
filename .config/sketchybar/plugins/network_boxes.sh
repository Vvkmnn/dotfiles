#!/usr/bin/env sh

# Network Box Indicators - Beautiful shaded boxes for traffic visualization
TYPE=$1  # "up" or "down"
STATE_FILE="/tmp/sketchybar_network_boxes_state"

# Check connectivity
CONNECTED=0
for iface in en0 en1; do
    if ifconfig $iface 2>/dev/null | grep -q 'status: active'; then
        CONNECTED=1
        break
    fi
done

if [ $CONNECTED -eq 0 ]; then
    # No connection - dark gray boxes
    sketchybar --set network_down_box label="■" label.color=0xff404040 label.font="SF Pro:Regular:8.0" \
               --set network_up_box label="■" label.color=0xff404040 label.font="SF Pro:Regular:8.0"
    exit 0
fi

# Get current network bytes
BYTES=$(netstat -ibn | awk '/^en[0-3].*<Link#/{rx+=$7; tx+=$10} END{print rx, tx}')
NOW=$(date +%s)

if [ -f "$STATE_FILE" ]; then
    read PREV_TIME PREV_RX PREV_TX < "$STATE_FILE"
    
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
    
    # Function to get box representation based on traffic (elegant grayscale)
    get_box_display() {
        local kb_rate=$1
        
        if [ $kb_rate -eq 0 ]; then
            # No traffic - small dark box
            echo "■" "0xff404040" "8.0"
        elif [ $kb_rate -lt 10 ]; then
            # Very light traffic - slightly lighter
            echo "■" "0xff606060" "9.0"
        elif [ $kb_rate -lt 100 ]; then
            # Light traffic - medium gray
            echo "■" "0xff808080" "10.0"
        elif [ $kb_rate -lt 500 ]; then
            # Medium traffic - lighter gray, larger
            echo "■" "0xffA0A0A0" "11.0"
        else
            # Heavy traffic - brightest, largest
            echo "■" "0xffC0C0C0" "12.0"
        fi
    }
    
    if [ "$TYPE" = "down" ]; then
        BOX_DATA=$(get_box_display $DOWN_KB)
        SYMBOL=$(echo $BOX_DATA | awk '{print $1}')
        COLOR=$(echo $BOX_DATA | awk '{print $2}')
        SIZE=$(echo $BOX_DATA | awk '{print $3}')
        sketchybar --set network_down_box label="$SYMBOL" label.color=$COLOR label.font="SF Pro:Regular:$SIZE"
    elif [ "$TYPE" = "up" ]; then
        BOX_DATA=$(get_box_display $UP_KB)
        SYMBOL=$(echo $BOX_DATA | awk '{print $1}')
        COLOR=$(echo $BOX_DATA | awk '{print $2}')
        SIZE=$(echo $BOX_DATA | awk '{print $3}')
        sketchybar --set network_up_box label="$SYMBOL" label.color=$COLOR label.font="SF Pro:Regular:$SIZE"
    fi
    
else
    # First run - initialize with inactive boxes
    sketchybar --set network_down_box label="■" label.color=0xff404040 label.font="SF Pro:Regular:8.0" \
               --set network_up_box label="■" label.color=0xff404040 label.font="SF Pro:Regular:8.0"
fi

# Save state (only once per call to avoid duplicate writes)
if [ "$TYPE" = "down" ]; then
    RX=$(echo "$BYTES" | awk '{print $1}')
    TX=$(echo "$BYTES" | awk '{print $2}')
    echo "$NOW $RX $TX" > "$STATE_FILE"
fi