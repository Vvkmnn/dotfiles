#!/usr/bin/env sh

# IP address display - flash icon only on network activity
WIFI_STATUS=$(ifconfig en0 2>/dev/null | grep 'status: active')
ETH_STATUS=$(ifconfig en1 2>/dev/null | grep 'status: active')

if [ -n "$WIFI_STATUS" ] || [ -n "$ETH_STATUS" ]; then
    # We're connected - get IP
    IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null)
    
    # Check network activity
    CURRENT_FILE="/tmp/sketchybar_ip_current"
    PREV_FILE="/tmp/sketchybar_ip_prev"
    
    # Get current network stats
    CURRENT_DOWN=$(netstat -ibn | grep -E "^en[0-3]" | awk '{sum+=$7} END {print sum}')
    CURRENT_UP=$(netstat -ibn | grep -E "^en[0-3]" | awk '{sum+=$10} END {print sum}')
    
    # Save current stats
    echo "$CURRENT_DOWN $CURRENT_UP" > "$CURRENT_FILE"
    
    # Check if there's activity
    ICON_COLOR=0xffFFFFFF  # Default white icon
    ACTIVITY_FILE="/tmp/sketchybar_ip_activity"
    
    if [ -f "$PREV_FILE" ]; then
        PREV_DOWN=$(cat "$PREV_FILE" | cut -d' ' -f1)
        PREV_UP=$(cat "$PREV_FILE" | cut -d' ' -f2)
        
        DIFF_DOWN=$((CURRENT_DOWN - PREV_DOWN))
        DIFF_UP=$((CURRENT_UP - PREV_UP))
        
        # If there's ANY activity, icon turns kanagawa yellow
        if [ $DIFF_DOWN -gt 0 ] || [ $DIFF_UP -gt 0 ]; then
            ICON_COLOR=0xffDDB670  # Kanagawa yellow for any activity
            echo "$(date +%s)" > "$ACTIVITY_FILE"  # Record activity time
        else
            # Check if we had recent activity (within 2 seconds)
            if [ -f "$ACTIVITY_FILE" ]; then
                LAST_ACTIVITY=$(cat "$ACTIVITY_FILE")
                CURRENT_TIME=$(date +%s)
                TIME_DIFF=$((CURRENT_TIME - LAST_ACTIVITY))
                
                if [ $TIME_DIFF -lt 2 ]; then
                    ICON_COLOR=0xffDDB670  # Keep yellow for 2 seconds
                else
                    rm -f "$ACTIVITY_FILE"
                fi
            fi
        fi
    fi
    
    # Move previous file
    mv "$CURRENT_FILE" "$PREV_FILE" 2>/dev/null
    
    if [ -n "$IP" ]; then
        sketchybar --set ip label="$IP" \
                           label.color=0xffFFFFFF \
                           icon.color=$ICON_COLOR \
                           icon.drawing=on \
                           label.drawing=on \
                           padding_left=0 \
                           padding_right=6
    else
        # Connected but no IP yet
        sketchybar --set ip label="..." \
                           label.color=0xffFFFFFF \
                           icon.color=$ICON_COLOR \
                           icon.drawing=on \
                           label.drawing=on \
                           padding_left=0 \
                           padding_right=6
    fi
else
    # Not connected - hide completely
    sketchybar --set ip icon.drawing=off \
                       label.drawing=off \
                       padding_left=0 \
                       padding_right=0
fi