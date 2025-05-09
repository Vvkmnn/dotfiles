#!/usr/bin/env bash

DOWN=0
UP=0
DOWN_FORMAT="0 kbps"
UP_FORMAT="0 kbps"

if ! command -v ifstat &> /dev/null
then
    sketchybar -m --set network.down label="N/A (ifstat?)" icon.highlight=off \
                  --set network.up label="N/A (ifstat?)" icon.highlight=off
    exit 0
fi

UPDOWN=$(ifstat -i "en0" -b 0.1 1 | tail -n1)
# Check if UPDOWN has content, it might be empty if interface en0 is not active
if [ -n "$UPDOWN" ]; then
    DOWN=$(echo "$UPDOWN" | awk "{ print \$1 }" | cut -f1 -d ".")
    UP=$(echo "$UPDOWN" | awk "{ print \$2 }" | cut -f1 -d ".")

    # Ensure DOWN and UP are numbers, default to 0 if not (e.g. if awk fails)
    [[ "$DOWN" =~ ^[0-9]+$ ]] || DOWN=0
    [[ "$UP" =~ ^[0-9]+$ ]] || UP=0

    if [ "$DOWN" -gt "999" ]; then
        DOWN_FORMAT=$(echo "$DOWN" | awk '{ printf "%03.0f Mbps", $1 / 1000}')
    else
        DOWN_FORMAT=$(echo "$DOWN" | awk '{ printf "%03.0f kbps", $1}')
    fi

    if [ "$UP" -gt "999" ]; then
        UP_FORMAT=$(echo "$UP" | awk '{ printf "%03.0f Mbps", $1 / 1000}')
    else
        UP_FORMAT=$(echo "$UP" | awk '{ printf "%03.0f kbps", $1}')
    fi
fi

sketchybar -m --set network.down label="$DOWN_FORMAT" icon.highlight=$(if [ "$DOWN" -gt "0" ]; then echo "on"; else echo "off"; fi) \
	--set network.up label="$UP_FORMAT" icon.highlight=$(if [ "$UP" -gt "0" ]; then echo "on"; else echo "off"; fi)
