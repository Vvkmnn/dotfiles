#!/usr/bin/env sh

# Centisecond component for clock (two digits, no trailing spaces)
NS=$(date '+%N' 2>/dev/null)

if [ "$NS" = "%N" ] || [ -z "$NS" ]; then
    CENTIS=$(python3 -c 'import time; print(f"{int((time.time()%1)*100):02d}")' 2>/dev/null)
else
    CENTIS=$(printf "%s" "$NS" | cut -c1-2)
fi

[ -z "$CENTIS" ] && CENTIS="00"

sketchybar --set clock_ms label=".$CENTIS"
